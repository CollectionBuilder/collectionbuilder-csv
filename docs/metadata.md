# Metadata Standards for CB Stand Alone

See general documentation: https://collectionbuilder.github.io/docs/metadata.html

## Required fields

- `objectid`: unique string, all lowercase with no spaces or special characters as it will used to form the item’s URL. Underscores (_) and dashes (-) are okay; slashes (/) should NOT be used in this field. Objects without an objectid will not be displayed in the collection. Objects with non-unique objectid will be overwritten.
- `title`: string description of object, used through out the template in representations of the object. *A title is not technically required, but will leave blanks areas in the template.*

## Object Download and Display images

- `object_download`: a full URL to download the full quality digital object or relative path if items are contained with in the project.
- `image_small`: a full URL to a small image representation of the object or relative path if items are contained with in the project.
- `image_thumb`: a full URL to a thumb image representation of the object or relative path if items are contained with in the project.
- `format`: object's MIME media type. If an object does not have an image_small or image_thumb, format is used by template logic to switch between different icons.

Each object will likely have an object_download value, the link where the digital file can be downloaded (or potentially accessed in a different platform). 
It is not a required field--items without an object_download will become metadata only records.

For display images in various visualizations the template checks the fields image_small and image_thumb for links to image derivatives.
If image derivatives are not available (i.e. the field is left blank), the logic will select icons or alternatives based on the format field.

These fields should be filed out in your spreadsheet using formulas / recipes depending on where your objects are hosted. 
This provides flexibility to include objects from multiple sources and to generate the URLs using a variety of approaches without needing to modify the template code.
CollectionBuilder-CSV aims to provide API recipes to generate the links for a variety of hosting solutions--but this work is done on the metadata, not embedded in the collectionbuilder-csv template code logic.

If the objects are included within the project repository use the relative path starting with `/` from the root of the repository. 
For example if some images are in the "objects" folder, use a relative path, e.g. `/objects/example_object.jpg`.
The relative path will be converted into a full URL during build.
Do not include the `baseurl` value that you set in "_config.yml", since this will be added by the template.

## Object Template

- `object_template`: a template type used in logic to set up different Item page features. If blank the object will default to a generic item page. Default supported options: `image`,`pdf`, `video`, `audio`, `youtube-embed`. See docs/item-pages.md for details.
