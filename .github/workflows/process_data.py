import json
import logging
import os
import unicodedata
from urllib.parse import urljoin, urlparse

import pandas as pd
import requests

# Configuration
OMEKA_API_URL = os.getenv("OMEKA_API_URL")
KEY_IDENTITY = os.getenv("KEY_IDENTITY")
KEY_CREDENTIAL = os.getenv("KEY_CREDENTIAL")
ITEM_SET_ID = os.getenv("ITEM_SET_ID")
if not ITEM_SET_ID:
    raise ValueError("ITEM_SET_ID environment variable must be set")
try:
    ITEM_SET_ID = int(ITEM_SET_ID)
except ValueError:
    raise ValueError("ITEM_SET_ID must be a valid integer")
CSV_PATH = os.getenv("CSV_PATH", "_data/sgb-metadata-csv.csv")
JSON_PATH = os.getenv("JSON_PATH", "_data/sgb-metadata-json.json")

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


# --- Helper Functions for Data Extraction ---
def is_valid_url(url):
    """Checks if a URL is valid."""
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


def download_file(url, dest_path):
    """Downloads a file from a given URL to the specified destination path."""
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    try:
        # Add timeout for file downloads as well
        with requests.get(url, stream=True, timeout=30) as r:
            r.raise_for_status()
            with open(dest_path, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
    except requests.exceptions.RequestException as err:
        logging.error(f"File download error: {err}")
        raise


def get_paginated_items(url, params):
    """Fetches all items from a paginated API endpoint."""
    items = []
    while url:
        try:
            # Add timeout to prevent hanging on slow/unresponsive servers
            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()
            items.extend(response.json())
        except (requests.exceptions.RequestException, json.JSONDecodeError) as err:
            logging.exception(f"Error fetching items from {url}: {err}")
            raise
        url = response.links.get("next", {}).get("url")
        params = None

    return items


def get_items_from_collection(collection_id):
    """Fetches all items from a specified collection."""
    params = {
        "item_set_id": collection_id,
        "key_identity": KEY_IDENTITY,
        "key_credential": KEY_CREDENTIAL,
        "per_page": 100,
    }
    return get_paginated_items(urljoin(OMEKA_API_URL, "items"), params)


def get_media(item_id):
    """Fetches media associated with a specific item ID."""
    params = {"key_identity": KEY_IDENTITY, "key_credential": KEY_CREDENTIAL}
    return get_paginated_items(
        urljoin(OMEKA_API_URL, f"media?item_id={item_id}"), params
    )


# --- Data Extraction and Transformation Functions ---
def extract_property(props, prop_id, as_uri=False):
    """Extracts a property value or URI from properties based on property ID."""
    for prop in props:
        if prop.get("property_id") == prop_id:
            if as_uri:
                return f"[{prop.get('o:label', '')}]({prop.get('@id', '')})"
            return prop.get("@value", "")
    return ""


def extract_property_by_term(props, term, as_uri=False):
    """Extracts a property value or URI from properties list."""
    # Since props is already a list of values for dcterms:abstract,
    # we just need to extract the first available value
    for prop in props:
        if as_uri:
            return f"[{prop.get('o:label', '')}]({prop.get('@id', '')})"
        return prop.get("@value", "")
    return ""


def extract_combined_values(props):
    """Combines text values and URIs from properties into a single list."""
    values = [
        prop.get("@value", "").replace(";", "&#59")
        for prop in props
        if "@value" in prop
    ]
    uris = [
        f"[{prop.get('o:label', '').replace(';', '&#59')}]({prop.get('@id', '').replace(';', '&#59')})"
        for prop in props
        if "@id" in prop
    ]
    return values + uris


def extract_alt_text(item_or_media):
    """Extracts alt text from dcterms:abstract field, with fallback to o:alt_text."""
    # First try to get dcterms:abstract (the new alt attribute field)
    abstract_props = item_or_media.get("dcterms:abstract", [])
    if abstract_props:
        alt_text = extract_property_by_term(abstract_props, "abstract")
        if alt_text:
            return alt_text
    
    # Fallback to the old o:alt_text field for backward compatibility
    return item_or_media.get("o:alt_text", "")


def extract_combined_values_csv(props):
    """Combines text values and URIs into a semicolon-separated string."""
    combined = extract_combined_values(props)
    return ";".join(combined)


def download_thumbnail(image_url):
    """Downloads the thumbnail image if the URL is valid."""
    if image_url and is_valid_url(image_url):
        filename = os.path.basename(image_url)
        local_image_path = f"objects/{filename}"
        if not os.path.exists(local_image_path):
            download_file(image_url, local_image_path)
        return local_image_path
    return ""


def infer_display_template(format_value):
    """Infers the display template type based on the format value."""
    if "image" in format_value.lower():
        return "image"
    elif "pdf" in format_value.lower():
        return "pdf"
    elif "geo+json" in format_value.lower():
        return "geodata"
    else:
        return "record"


def extract_item_data(item):
    """Extracts relevant data from an item and downloads its thumbnail if available."""
    local_image_path = (
        download_thumbnail(item.get("thumbnail_display_urls", {}).get("large", ""))
        if item.get("o:is_public", False)
        else "assets/img/placeholder.svg"
    )

    return {
        "objectid": extract_property(item.get("dcterms:identifier", []), 10),
        "parentid": "",
        "title": extract_property(item.get("dcterms:title", []), 1),
        "description": extract_property(item.get("dcterms:description", []), 4),
        # "subject": extract_combined_values(item.get("dcterms:subject", [])),
        "coverage": extract_property(item.get("dcterms:temporal", []), 41),
        "isPartOf": extract_combined_values(item.get("dcterms:isPartOf", [])),
        "creator": extract_combined_values(item.get("dcterms:creator", [])),
        "publisher": extract_combined_values(item.get("dcterms:publisher", [])),
        "source": extract_combined_values(item.get("dcterms:source", [])),
        "date": extract_property(item.get("dcterms:date", []), 7),
        "type": extract_property(item.get("dcterms:type", []), 8, as_uri=True),
        "format": extract_property(item.get("dcterms:format", []), 9),
        "extent": extract_property(item.get("dcterms:extent", []), 25),
        "language": extract_property(item.get("dcterms:language", []), 12),
        "relation": extract_combined_values(item.get("dcterms:relation", [])),
        "rights": extract_property(item.get("dcterms:rights", []), 15),
        "license": extract_property(item.get("dcterms:license", []), 49),
        "display_template": "compound_object",
        "object_location": "",
        "image_small": local_image_path,
        "image_thumb": local_image_path,
        "image_alt_text": extract_alt_text(item),
    }


def extract_media_data(media, item_dc_identifier):
    """Extracts relevant data from a media item associated with a specific item."""
    format_value = extract_property(media.get("dcterms:format", []), 9)
    display_template = infer_display_template(format_value)

    # Download the thumbnail image if available and valid
    if "platzhalter" in media.get("o:source", ""):
        local_image_path = "assets/img/placeholder.svg"
    elif "application/geo+json" in format_value:
        local_image_path = "assets/lib/icons/sgb-globe.svg"
    elif "text/csv" in format_value:
        local_image_path = "assets/lib/icons/table.svg"
    else:
        local_image_path = (
            download_thumbnail(media.get("thumbnail_display_urls", {}).get("large", ""))
            or "assets/img/no-image.svg"
        )

    # Extract media data
    object_location = (
        media.get("o:original_url", "") if media.get("o:is_public", False) else ""
    )

    logging.info(f"Media ID: {media['o:id']}")
    logging.info(f"is_public: {media.get('o:is_public')}")

    return {
        "objectid": extract_property(media.get("dcterms:identifier", []), 10),
        "parentid": item_dc_identifier,
        "title": extract_property(media.get("dcterms:title", []), 1),
        "description": extract_property(media.get("dcterms:description", []), 4),
        # "subject": extract_combined_values(media.get("dcterms:subject", [])),
        "coverage": extract_property(media.get("dcterms:temporal", []), 41),
        "isPartOf": extract_combined_values(media.get("dcterms:isPartOf", [])),
        "creator": extract_combined_values(media.get("dcterms:creator", [])),
        "publisher": extract_combined_values(media.get("dcterms:publisher", [])),
        "source": extract_combined_values(media.get("dcterms:source", [])),
        "date": extract_property(media.get("dcterms:date", []), 7),
        "type": extract_property(media.get("dcterms:type", []), 8, as_uri=True),
        "format": format_value,
        "extent": extract_property(media.get("dcterms:extent", []), 25),
        "language": extract_property(media.get("dcterms:language", []), 12),
        "relation": extract_combined_values(media.get("dcterms:relation", [])),
        "rights": extract_property(media.get("dcterms:rights", []), 15),
        "license": extract_property(media.get("dcterms:license", []), 49),
        "display_template": display_template,
        "object_location": object_location,
        "image_small": local_image_path,
        "image_thumb": local_image_path,
        "image_alt_text": extract_alt_text(media),
    }


def normalize_record(record):
    """Normalizes all string fields in a record to Unicode NFC form."""
    return {
        key: unicodedata.normalize("NFC", value) if isinstance(value, str) else value
        for key, value in record.items()
    }


# --- Main Processing Function ---
def main():
    # Fetch item data
    logging.info(f"Fetching items from collection {ITEM_SET_ID} at {OMEKA_API_URL}")
    items_data = get_items_from_collection(ITEM_SET_ID)
    
    # Validate that we received some data
    if not items_data:
        logging.error("No items received from Omeka API. This could indicate a timeout or API unavailability.")
        logging.error("Canceling deployment to prevent deploying empty site.")
        raise ValueError("No items received from Omeka API")
    
    logging.info(f"Successfully retrieved {len(items_data)} items from collection")

    # Process each item and associated media
    items_processed = []
    for item in items_data:
        item_record = extract_item_data(item)
        items_processed.append(item_record)
        media_data = get_media(item.get("o:id", ""))
        if media_data:
            for media in media_data:
                items_processed.append(
                    extract_media_data(media, item_record["objectid"])
                )

    # Normalize all string fields in the records to avoid decomposed Unicode form Umlaute ¨ + o -> ö
    items_normalized = [normalize_record(record) for record in items_processed]
    
    # Final validation - ensure we have processed records
    if not items_normalized:
        logging.error("No records were processed successfully. Canceling deployment.")
        raise ValueError("No records were processed successfully")

    # Save data to CSV and JSON formats
    save_to_files(items_normalized, CSV_PATH, JSON_PATH)


def save_to_files(records, csv_path, json_path):
    """Saves data to both CSV and JSON files."""
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False)
    logging.info(f"JSON file has been saved to {json_path}")

    # Convert list of records to a DataFrame and save as CSV
    records = [
        {
            key: ";".join(value) if isinstance(value, list) else value
            for key, value in record.items()
        }
        for record in records
    ]
    df = pd.DataFrame(records)
    df.to_csv(csv_path, index=False)
    logging.info(f"CSV file has been saved to {csv_path}")


if __name__ == "__main__":
    main()
