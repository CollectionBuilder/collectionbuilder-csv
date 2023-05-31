# Item pages

CollectionBuilder-CSV uses "CollectionBuilder Page Generator" plugin to generate individual pages for each record in the collection metadata on the fly.

Typical use requires no configuration.
CB Page Gen will automatically generate pages from the data specified by "_config.yml" `metadata` (the same as used to populate the rest of the site).
For more advanced configuration options, including generating other types of pages, see "docs/plugins.md".

CB Page Gen passes all metadata fields through to Jekyll as if each was front matter on a normal file so that the values can be used to populate Item page content.
This page object is passed to the layout matching the `display_template` value set in each item's metadata, falling back to the default `template` value (normally `item`).

## display_template Layouts 

The `display_template` layouts provide templates for presenting different item types.
The files are found in "_layouts/item/".
Look for comments in each layout's front matter for information.

Each display_template layout is typically constructed of modular item page components (found in "_includes/item/") and arranged using Bootstrap.
This simplifies customization and creation of different item pages depending on collection needs.

Default supported options include: `image`,`pdf`, `video`, `audio`, `panorama`, `record`, `item`, `multiple`, and `compound_object`. 

- `image`: Displays image_small if available, with fall back to object_location. Adds gallery view to open images full screen using object_location, with fall back to image_small.
- `pdf`: Displays image_small if available, with fall back to image_thumb, or a pdf icon.
- `video`: Displays a video embedded on the page with default support for video files (using `<video>` element with object_location as src), YouTube (from link in object_location), or Vimeo videos (from link in object_location).
- `audio`: Uses `<audio>` element to embed audio file from object_location as src.
- `panorama`: a 360 degree image. Item pages will use the Javascript based panorama viewer, [Panellum](https://pannellum.org/) to display the image in a 360 degree view.
- `record`: metadata only record.
- `item`: generic fallback item page, displays image or icon depending on "image_thumb"
- `compound_object`: a record for a object that includes multiple file instances that are described/managed separately in the metadata. Compound objects use their own set of conventions, see "docs/compound_objects.md" for details.
- `multiple`: a record for a object that includes multiple images (such as a postcard) that are listed separately in the metadata. Multiples use their own set of conventions, see "docs/compound_objects.md" for details.

Each of these layouts in turn is generally given `layout: item-page-base`, so that the custom features of the display templates will share the same standard page layout.
If you want to change the basic structure of all items pages (breadcrumbs and title at top, citation and rights at button), edit the "_layouts/item/item-page-base.html" or the relevant item includes. 

To create a new custom template, create a ".html" file in the "_layouts/item/" folder. 
Add front matter to the top of the file (i.e. `---` front matter lines `---`).
You can use `layout: item-page-base` to inherit the default styles, or you can skip to `layout: page` or `layout: default` to have a completely custom page.

## Item Page Components

Components intended for use in Item page layouts can be found in "_includes/item".
They can be included in the layouts following the pattern `{% include item/component-name.html %}`.
Look for information about each include in the comments at the top of the file.

The components use Liquid to pull item metadata into the content elements. 
Since the metadata is provided with the page object, fields can be accessed following the pattern `{{ page.field_name }}`.

Compound object display_template types use a specialized subset of includes in "_includes/item/child", which make use of the pattern {{ child.field_name }} to pull child item metadata rows, in to the parent Item page.

Below are a few notes on special item components:

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

### image-gallery

For image items, a zoomable, full screen gallery view is added using [Spotlight gallery](https://github.com/nextapps-de/spotlight).
Ensure dependencies are added by including `gallery: true` in the layout front matter.
See "docs/gallery.md" for more details.

### metadata 

The metadata fields displayed on an item page are configured by "config-metadata.csv". 

Only fields with a value in the "display_name" column will be displayed, and only if the item has a value for that field. 
(*Note:* if you want a field to display without a field name visible, enter a blank space in the "display_name" column)

Fields with "true" in the "browse_link" column in config-metadata will generate a link to the Browse page. 
Values in "browse_link" fields will be split on semicolon `;` as multi-valued fields before adding links.
These often mirror the "btn" links on the Browse config-browse. 
Keep in mind that for the browse links to be useful, the field must also be available to filter on the Browse page--so the field should also appear in "config-browse.csv" (displayed, btn, or hidden). 

## Item Meta Markup

The default `item-page-base` layout has the front matter value `item-meta: true`.
This will pull specialized meta markup in head from "_includes/head/item-meta.html" designed to help search indexing, social sharing, and SEO.
The mark up is configured using "_data/config-metadata.csv" and driven by the metadata fields (see "docs/markup.md").

If you create a new custom layout that does not use `layout: item-page-base`, you will want to add `item-meta: true` to your layout front matter.
