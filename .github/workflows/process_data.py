import os
import pandas as pd
import requests
from urllib.parse import urlparse, parse_qs

OMEKA_API_URL = os.environ.get("OMEKA_API_URL")
KEY_IDENTITY = os.environ.get("KEY_IDENTITY")
KEY_CREDENTIAL = os.environ.get("KEY_CREDENTIAL")
ITEM_SET_ID = os.environ.get("ITEM_SET_ID")   

def get_items_from_collection(collection_id):
    url = OMEKA_API_URL + "items"
    all_items = []
    params = {
        "item_set_id": collection_id,
        "key_identity": KEY_IDENTITY,
        "key_credential": KEY_CREDENTIAL,
    }

    while True:
        response = requests.get(url, params=params)
        if response.status_code != 200:
            print(f"Error: {response.status_code}")
            break

        # Add the items from the current page to our list
        all_items.extend(response.json())

        # Check if there is a 'next' page
        links = requests.utils.parse_header_links(response.headers.get("Link", ""))
        next_link = [link for link in links if link["rel"] == "next"]
        if not next_link:
            break

        # Update the URL for the next request
        next_url = next_link[0]["url"]
        url_parsed = urlparse(next_url)
        next_params = parse_qs(url_parsed.query)
        params.update(next_params)

    return all_items


def get_media(item_id):
    url = OMEKA_API_URL + "media/" + str(item_id)
    params = {"key_identity": KEY_IDENTITY, "key_credential": KEY_CREDENTIAL}
    response = requests.get(url, params=params)
    if response.status_code != 200:
        print(f"Error: {response.status_code}")
        return None
    return response.json()


def media_type(media_list, index=None):
    if not media_list:
        return "record"
    if len(media_list) > 1 and index is None:
        media_types = [media.get("o:media_type") for media in media_list]
        if all([media_type.startswith("image") for media_type in media_types]):
            return "multiple"
        return "compound_object"
    media = media_list[index] if index is not None else media_list[0]
    media_type = media.get("o:media_type")
    if media_type.startswith("image"):
        return "image"
    if media_type.startswith("audio"):
        return "audio"
    if media_type.startswith("video"):
        return "video"
    if media_type.startswith("application/pdf"):
        return "pdf"
    return "record"


def map_columns(item_set):
    return_list = []
    for data in item_set:
        media_list = [
            get_media(media_item.get("o:id")) for media_item in data.get("o:media", [])
        ]
        type = media_type(media_list)
        media = media_list[0] if media_list else {}
        media_data = create_media_data_dict(data, media, type)
        return_list.append(media_data)
        if len(media_list) > 1:
            for index, media in enumerate(media_list):
                type_child = media_type(media_list, index)
                media_data = create_media_data_dict(data, media, type_child, index)
                return_list.append(media_data)
    return return_list


def create_media_data_dict(data, media, type, index=None):
    media_id_suffix = f"_{index}" if index is not None else ""
    media_url = (
        media.get("thumbnail_display_urls", {}).get("large")
        if media
        and media.get("thumbnail_display_urls", {}).get("large", "").startswith("http")
        else None
    )
    media_original_url = (
        media.get("o:original_url")
        if media and
        (len(data.get("o:media", [])) > 1 and
         index is not None) and
        media.get("o:original_url", "").startswith("http") and media.get("o:is_public")
        else None
    )
    media_title = (
        media.get("o:title")
        if index is not None
        else data.get("dcterms:title", [{}])[0].get("@value")
    )

    return {
        "objectid": data.get("dcterms:identifier", [{}])[0].get("@value").lower()
        + media_id_suffix,
        "parentid": None
        if index is None
        else data.get("dcterms:identifier", [{}])[0].get("@value").lower(),
        "title": media_title,
        "creator": data.get("dcterms:creator", [{}])[0].get("@value"),
        "date": data.get("dcterms:date", [{}])[0].get("@value"),
        "era": data.get("dcterms:temporal", [{}])[0].get("@value"),
        "description": data.get("dcterms:description", [{}])[0].get("@value"),
        "subject": "; ".join(
            [item.get("@value", "") for item in data.get("dcterms:subject", [])]
        ),
        "publisher": data.get("dcterms:publisher", [{}])[0].get("@value"),
        "source": data.get("dcterms:source", [{}])[0].get("@value"),
        "relation": data.get("dcterms:relation", [{}])[0].get("@value"),
        "hasVersion": data.get("dcterms:hasVersion", [{}])[0].get("@value"),
        "type": data.get("dcterms:type", [{}])[0].get("@id"),
        "format": data.get("dcterms:format", [{}])[0].get("@value"),
        "extent": data.get("dcterms:extent", [{}])[0].get("@value"),
        "language": data.get("dcterms:language", [{}])[0].get("o:label"),
        "rights": "; ".join(
            [item.get("@value", "") for item in data.get("dcterms:rights", [])]
        ),
        "license": data.get("dcterms:license", [{}])[0].get("@value"),
        "isPartOf": data.get("dcterms:isPartOf", [{}])[0].get("@value"),
        "isReferencedBy": data.get("dcterms:isReferencedBy", [{}])[0].get("@value"),
        "display_template": type,
        "object_location": media_original_url,
        "image_small": media_url,
        "image_thumb": media_url,
        "image_alt_text": None,
        "object_transcript": None,
    }


item_set = get_items_from_collection(ITEM_SET_ID)
item_set_mapped = map_columns(item_set)
item_set_mapped_df = pd.DataFrame(item_set_mapped)
item_set_mapped_df.to_csv("_data/sgb-metadata.csv", index=False)
