import logging
import os
from urllib.parse import urljoin, urlparse

import pandas as pd
import requests

# Configuration
OMEKA_API_URL = os.getenv("OMEKA_API_URL")
KEY_IDENTITY = os.getenv("KEY_IDENTITY")
KEY_CREDENTIAL = os.getenv("KEY_CREDENTIAL")
ITEM_SET_ID = os.getenv("ITEM_SET_ID")

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


# Function to get items from a collection
def get_items_from_collection(collection_id):
    url = urljoin(OMEKA_API_URL, "items")
    all_items = []
    params = {
        "item_set_id": collection_id,
        "key_identity": KEY_IDENTITY,
        "key_credential": KEY_CREDENTIAL,
        "per_page": 100,
    }

    while True:
        response = requests.get(url, params=params)
        if response.status_code != 200:
            logging.error(f"Error: {response.status_code}")
            break
        items = response.json()
        all_items.extend(items)
        next_url = None
        for link in response.links:
            if response.links[link]["rel"] == "next":
                next_url = response.links[link]["url"]
                break
        if not next_url:
            break
        url = next_url
    return all_items


# Function to get media for an item
def get_media(item_id):
    url = urljoin(OMEKA_API_URL, f"media?item_id={item_id}")
    params = {"key_identity": KEY_IDENTITY, "key_credential": KEY_CREDENTIAL}
    response = requests.get(url, params=params)
    if response.status_code != 200:
        logging.error(f"Error: {response.status_code}")
        return None
    return response.json()


# Function to download file
def download_file(url, dest_path):
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    try:
        with requests.get(url, stream=True) as r:
            r.raise_for_status()
            with open(dest_path, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
    except requests.exceptions.HTTPError as http_err:
        logging.error(f"HTTP error occurred: {http_err}")
    except Exception as err:
        logging.error(f"Other error occurred: {err}")


# Function to check if URL is valid
def is_valid_url(url):
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


# Helper functions to extract data
def extract_prop_value(props, prop_id):
    return next(
        (
            prop.get("@value", "")
            for prop in props
            if prop.get("property_id") == prop_id
        ),
        "",
    )


def extract_prop_uri(props, prop_id):
    return next(
        (
            f"[{prop.get('o:label', '')}]({prop.get('@id', '')})"
            for prop in props
            if prop.get("property_id") == prop_id
        ),
        "",
    )


def extract_combined_list(props):
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
    combined = values + uris
    return ";".join(combined)


def extract_item_data(item):
    # Download the thumbnail image if available and valid
    image_url = item.get("thumbnail_display_urls", {}).get("large", "")
    local_image_path = ""
    if image_url and is_valid_url(image_url):
        filename = os.path.basename(image_url)
        local_image_path = f"objects/{filename}"
        if not os.path.exists(local_image_path):
            download_file(image_url, local_image_path)

    logging.info(f"Item ID: {item['o:id']}")

    return {
        "objectid": extract_prop_value(item.get("dcterms:identifier", []), 10),
        "parentid": "",
        "title": extract_prop_value(item.get("dcterms:title", []), 1),
        "description": extract_prop_value(item.get("dcterms:description", []), 4),
        "subject": extract_combined_list(item.get("dcterms:subject", [])),
        "era": extract_prop_value(item.get("dcterms:temporal", []), 41),
        "isPartOf": extract_combined_list(item.get("dcterms:isPartOf", [])),
        "creator": extract_combined_list(item.get("dcterms:creator", [])),
        "publisher": extract_combined_list(item.get("dcterms:publisher", [])),
        "source": extract_combined_list(item.get("dcterms:source", [])),
        "date": extract_prop_value(item.get("dcterms:date", []), 7),
        "type": extract_prop_uri(item.get("dcterms:type", []), 8),
        "format": extract_prop_value(item.get("dcterms:format", []), 9),
        "extent": extract_prop_value(item.get("dcterms:extent", []), 25),
        "language": extract_prop_value(item.get("dcterms:language", []), 12),
        "relation": extract_combined_list(item.get("dcterms:relation", [])),
        "rights": extract_prop_value(item.get("dcterms:rights", []), 15),
        "license": extract_prop_value(item.get("dcterms:license", []), 49),
        "display_template": "compound_object",
        "object_location": "",
        "image_small": local_image_path,
        "image_thumb": local_image_path,
        "image_alt_text": item.get("o:alt_text", ""),
    }


def infer_display_template(format_value):
    if "image" in format_value.lower():
        return "image"
    elif "pdf" in format_value.lower():
        return "pdf"
    elif "geo+json" in format_value.lower():
        return "geodata"
    else:
        return "record"


def extract_media_data(media, item_dc_identifier):
    format_value = extract_prop_value(media.get("dcterms:format", []), 9)
    display_template = infer_display_template(format_value)

    # Download the thumbnail image if available and valid
    image_url = media.get("thumbnail_display_urls", {}).get("large", "")
    local_image_path = ""
    if image_url and is_valid_url(image_url):
        filename = os.path.basename(image_url)
        local_image_path = f"objects/{filename}"
        if not os.path.exists(local_image_path):
            download_file(image_url, local_image_path)

    # Extract media data
    object_location = (
        media.get("o:original_url", "") if media.get("o:is_public", False) else ""
    )

    logging.info(f"Media ID: {media['o:id']}")
    logging.info(f"is_public: {media.get('o:is_public')}")

    return {
        "objectid": extract_prop_value(media.get("dcterms:identifier", []), 10),
        "parentid": item_dc_identifier,
        "title": extract_prop_value(media.get("dcterms:title", []), 1),
        "description": extract_prop_value(media.get("dcterms:description", []), 4),
        "subject": extract_combined_list(media.get("dcterms:subject", [])),
        "era": extract_prop_value(media.get("dcterms:temporal", []), 41),
        "isPartOf": extract_combined_list(media.get("dcterms:isPartOf", [])),
        "creator": extract_combined_list(media.get("dcterms:creator", [])),
        "publisher": extract_combined_list(media.get("dcterms:publisher", [])),
        "source": extract_combined_list(media.get("dcterms:source", [])),
        "date": extract_prop_value(media.get("dcterms:date", []), 7),
        "type": extract_prop_uri(media.get("dcterms:type", []), 8),
        "format": format_value,
        "extent": extract_prop_value(media.get("dcterms:extent", []), 25),
        "language": extract_prop_value(media.get("dcterms:language", []), 12),
        "relation": extract_combined_list(media.get("dcterms:relation", [])),
        "rights": extract_prop_value(media.get("dcterms:rights", []), 15),
        "license": extract_prop_value(media.get("dcterms:license", []), 49),
        "display_template": display_template,
        "object_location": object_location,
        "image_small": local_image_path,
        "image_thumb": local_image_path,
        "image_alt_text": media.get("o:alt_text", ""),
    }


# Main function to download item set and generate CSV
def main():
    # Download item set
    collection_id = ITEM_SET_ID
    items_data = get_items_from_collection(collection_id)

    # Extract item data
    item_records = []
    media_records = []
    for item in items_data:
        item_record = extract_item_data(item)
        item_records.append(item_record)

        # Extract media data for each item
        item_dc_identifier = item_record["objectid"]
        media_data = get_media(item["o:id"])
        if media_data:
            for media in media_data:
                media_records.append(extract_media_data(media, item_dc_identifier))

    # Combine item and media records
    combined_records = item_records + media_records

    # Create DataFrame
    df = pd.DataFrame(combined_records)

    # Save to CSV
    csv_path = "_data/sgb-metadata.csv"
    os.makedirs(os.path.dirname(csv_path), exist_ok=True)
    df.to_csv(csv_path, index=False)

    logging.info(f"CSV file has been saved to {csv_path}")


if __name__ == "__main__":
    main()
