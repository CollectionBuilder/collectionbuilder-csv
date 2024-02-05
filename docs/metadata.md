# Metadata Standards for CB-CSV

See general documentation: <https://collectionbuilder.github.io/cb-docs/docs/metadata/>

## Required fields

- `objectid`: unique string, all lowercase with no spaces or special characters as it will used to form the item’s URL. Underscores (_) and dashes (-) are okay; slashes (/) should NOT be used in this field. Objects without an objectid will not be displayed in the collection. Objects with non-unique objectid will be overwritten.
- `title`: string description of object, used through out the template in representations of the object. *A title is not technically required, but will leave blanks areas in the template.*

## Object Download and Display images

These metadata values are optional, but provide representations of the items in site visualizations and item pages for your users:

- `object_location`: a full URL to download the full quality digital object or relative path if items are contained with in the project. This file is not used for display on the website, except in the case of image galleries on item pages.
- `image_small`: a full URL to a small image representation of the object or relative path if items are contained with in the project. If this field is filled, the image will be displayed to represent the item on Item pages or in features added to content pages.
- `image_thumb`: a full URL to a thumb image representation of the object or relative path if items are contained with in the project. If this field is filled, the image will be displayed to represent the item on visualization pages.
- `image_alt_text`: an appropriate textual description of the image_small/image_thumb representation of the item. This value will be used as the "alt" value of the image element. If no image_alt_text is provided, the template will fall back to using the item description or title value (which in many cases is not ideal for your users). Using the image_alt_text field allows you to provide more carefully crafted alt text depending on the item contents, type, and context.
- `object_transcript`: a text transcript of the item's content, most commonly used with video and audio items. The transcript can be added in two ways: 1. adding the full text as the value directly in the field. This is a straight forward way to keep transcript data directly in your metadata. Keep in mind that spreadsheet software typically has limits on the number of characters per cell, so this won't work well with larger transcripts. 2. add the relative path and filename of a transcript text file (.txt, .md, or partial .html) contained in the project repository (usually the "/objects/" folder). The value in "object_transcript" must start with "/" (indicating the root of the repository similar to other relative paths used in the template), e.g. `/objects/transcript1.txt`. The transcript text file must have yaml front matter at the top of the file so that it will be processed by Jekyll (the front matter can be empty, i.e. `---` line break `---`). The transcript text will be retrieved from the file and rendered as Markdown.
- `format`: object's MIME media type. If an object does not have an image_thumb, format is used by template logic to switch between different icons.

Each object will likely have an object_location value, the link where the digital file can be downloaded (or potentially accessed in a different platform). 
It is not a required field--items without an object_location will become metadata only records.

For display images in various visualization pages the template checks the fields image_thumb for links to image derivatives (Browse, Map, Timeline).
If image_thumb derivatives are not available (i.e. the field is left blank), the logic will select icons alternatives based on the display_template or format field.
If the item has neither display_template or format, it will fall back to a default icon.

These fields should be filed out in your spreadsheet using formulas / recipes depending on where your objects are hosted. 
This provides flexibility to include objects from multiple sources and to generate the URLs using a variety of approaches without needing to modify the template code.
CollectionBuilder-CSV aims to provide API recipes to generate the links for a variety of hosting solutions--but this work is done on the metadata, not embedded in the collectionbuilder-csv template code logic.

If the objects are included within the project repository use the relative path starting with `/` from the root of the repository. 
For example if some images are in the "objects" folder, use a relative path, e.g. `/objects/example_object.jpg`.
The relative path will be converted into a full URL during build.
Do not include the `baseurl` value that you set in "_config.yml", since this will be added by the template.

## Display Template

- `display_template`: a template type used in logic to set up different Item page features. If blank the object will default to a generic item page. Default supported options: `image`,`pdf`, `video`, `audio`, `panorama`, `record`, `item`, `multiple`, and `compound_object`. See docs/item-pages.md for details.
- `parentid`: used to designate child items in the "multiple" and "compound_object" templates, a unique string matching the objectid of the parent item. See docs/compound_objects.md for details.
