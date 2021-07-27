# Item pages

CollectionBuilder-CSV uses "CollectionBuilder Page Generator" plugin to generate individual pages for each record in the collection metadata on the fly.

Typical use requires no configuration.
CB Page Gen will automatically generate pages from the data specified by "_config.yml" `metadata` (the same as used to populate the rest of the site).
For more advanced configuration options, including generating other types of pages, see "docs/plugins.md".

CB Page Gen passes all metadata fields through to Jekyll as if each was front matter on a normal file so that the values can be used to populate Item page content.
This page object is passed to the layout matching the `display_template` value set in each item's metadata, falling back to the default `template` value (normally `item`).

## display_template Layouts 

The `display_template` layouts provide templates for presenting different item types.
The files are found in "_layouts/item/" (default item layouts have the front matter `item-meta: true`, which adds item meta markup).

Each display_template layout is typically constructed of modular item page components (found in "_includes/item/") and arranged using Bootstrap.
This simplifies customization of the different item pages depending on collection needs.

Default supported options: `image`,`pdf`, `video`, `audio`,  `record`, `item`. 

- `image`: Displays image_small if available, with fall back to object_location. Adds LightGallery view to open images full screen using object_location, with fall back to image_small.
- `pdf`: Displays image_small if available, with fall back to image_thumb, or a pdf icon.
- `video`: Displays a video embedded on the page with default support for video files (using `<video>` element with object_location as src), YouTube (from link in object_location), or Vimeo videos (from link in object_location).
- `audio`: Uses `<audio>` element to embed audio file from object_location as src.
- `record`: metadata only record.
- `item`: generic fallback item page, displays image or icon depending on "image_thumb"

## Item Page Components

Components intended for use in Item page layouts can be found in "_includes/item".
They can be included in the layouts following the pattern `{% include item/component-name.html %}`.

The components use Liquid to pull metadata into the content elements. 
Since the metadata is provided with the page object, fields can be accessed following the pattern `{{ page.field_name }}`.

Below are the default item includes:

### audio-player

Uses `<audio>` element to embed audio file from object_location as src.
Use this option if you are directly exposing audio files on the web, such as on a static server.

### breadcrumbs

Adds Bootstrap styled breadcrumbs to page.
By default the crumbs are: Home (index.html) / Items (browse.html) / current page title (from the metadata, truncated to 10 words max).

### browse-buttons

Item pages can have browsing buttons linking to previous/next item page. 
This option is turned off or on in _data/theme.yml:

```
# Item page 
browse-buttons: true 
```

Generating browse buttons adds some time to builds on very large collections, so can be turned off to save time during development, or if browse doesn't make sense for the collection content.
The item order follows the order in the metadata CSV, so pre-sort the CSV to the desired order.

Requires "cb_page_gen" plugin, which provides values for `page.previous_item` and `page.next_item`.

### citation-box

Add a "Preferred Citation" automatically generated using the item title (metadata title), collection (site.title), organization (site.organization-name), and a link to the item page.
The include can be edited to change the format or fields as necessary.

### download-buttons

Add download button with text based on format field.
Plus add hash link to Timeline if there is a date, and hash link to Map if there is latitude and longitude.

### image-gallery

For image items, a zoomable, full screen gallery view is added using [lightGallery](http://sachinchoolur.github.io/lightGallery/).
Ensure dependencies are added by including `gallery: true` in the layout front matter.
See "docs/lightgallery.md" for more details.

### item-thumb

Add a thumbnail image or icon (based on display_template or format) for an item, with a `object_location` link (if available).

### metadata 

The metadata fields displayed on an item page are configured by "config-metadata.csv". 

Only fields with a value in the "display_name" column will be displayed, and only if the item has a value for that field. 
(*Note:* if you want a field to display without a field name visible, enter a blank space in the "display_name" column)

Fields with "true" in the "browse_link" column in config-metadata will generate a link to the Browse page. 
Values in "browse_link" fields will be split on semicolon `;` as multi-valued fields before adding links.
These often mirror the "btn" links on the Browse config-browse. 
Keep in mind that for the browse links to be useful, the field must also be available to filter on the Browse page--so the field should also appear in "config-browse.csv" (displayed, btn, or hidden). 

### rights-box

A "Rights" box is automatically generated if either "rights" or "rightsstatement" field is in the metadata.
The layout assumes that "rightsstatement" is a link only, e.g. most likely from rightsstatements.org or Creative Commons, a value such as "http://rightsstatements.org/vocab/NoC-US/1.0/".
If your collection uses different field names for these values, either modify the field names in the metadata CSV, or edit the Rights box in the item layout. 

### video-embed

Adds an iframe embed for YouTube or Vimeo videos given a link in `object_location`.
For items without a YouTube or Vimeo link, falls back to an thumb/icon and link.

For items that are YouTube videos, please fill in the object_location field with the YouTube share link or watch link (e.g. `https://youtu.be/dbKNr3wuiuQ` or `https://www.youtube.com/watch?v=dbKNr3wuiuQ`).
In most cases you will want to ensure the youtubeid is the end of URL (e.g. `dbKNr3wuiuQ`, and does *not* end with other query strings such as `?t=51` or `&feature=youtu.be`). 
The template will parse the `object_location` link to find the youtube id and set up a iframe embed using the modest branding and privacy options. 

For items that are Vimeo videos, please fill in the object_location field with the full Vimeo link, e.g. `https://vimeo.com/330826859`.
The template will parse the `object_location` link to find the vimeo id and set up a iframe embed using the modest branding and privacy options. 

### video-player

Uses `<video>` element to embed a video file from `object_location` as src.
Use this option if you are directly exposing video files on the web, such as on a static server.

## Item Meta Markup

The default item layouts have the front matter value `item-meta: true`.
This will pull specialized meta markup in head from "_includes/head/item-meta.html" designed to help search indexing, social sharing, and SEO.
The mark up is configured using "_data/config-metadata.csv" and driven by the metadata fields (see "docs/markup.md").
