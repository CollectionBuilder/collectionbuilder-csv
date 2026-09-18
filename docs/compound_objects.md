# Compound Objects

"Compound objects" are a concept used in some repository platforms to describe items that are made up of a set of digital files intended to be treated as one singular connected resource in the system.

CollectionBuilder uses a specific metadata convention to represent this type of item, and provides several built in "display_template" options that make use of this structure.
The general convention is flexible and often useful for structuring other custom item types.

## Metadata Convention

Compound objects can be added to CollectionBuilder following a parent/child convention in your metadata spreadsheet.
A top level parent metadata record describes the object overall; one or more related child metadata records are connected to the parent record.
This allows each child object to be fully described individually (or not) using your full metadata template.

- Your metadata spreadsheet must have an "objectid" and "parentid" column.
- "parentid" will be blank for all normal items.
- A parent metadata record is created for each compound object. 
    - Parent "parentid" is blank. 
    - The parent will use a compound object "display_template" value (`compound_object`, `multiple`, or other custom type).
    - A parent can have 1 or more related child records.
    - Parent rows will generate an Item page in your site.
    - The image listed in image_thumb and image_small of the parent will be used to represent the item in all visualizations.
- A child metadata record is created to represent each related sub-item.
    - Child requires a unique "objectid" (like all items)
    - Child requires a "parentid" value that matches their parent's "objectid". e.g. If the parent's "objectid" is `example002`, then all related children should have `example002` in their "parentid" field.
    - Child rows will NOT generate an Item page in your site, they will only be pulled into their parent's Item page.

Please look at the demo compound object metadata ("_data/demo-compoundobjects-metadata.csv") for an example of how this might look in the metadata, and see the demo CollectionBuilder-CSV site for how this looks in operation. 

## Display Templates

CollectionBuild provides some built in display_template values that make use of the compound object style metadata structure. 
These display_template values are applied ONLY to the parent item. 
Child items will use their own display_template, generally based on their media type (image, pdf, video, etc).

### compound_object 

A "compound_object" item can include a set of objects with any media type that CollectionBuilder handles, i.e. image, pdf, video, audio, panorama (CB-CSV only), or record.

- Parent items with the display_template value of `compound_object` will generate an Item page featuring a grid of cards representing item thumbnails for each child object. Clicking the child thumbnails opens a child object page as a modal. The child modal has similar features to the display of an individual item page, but maintains the context of the compound object parent. 
- "compound_object" use case examples:
    - **Scrapbook**: to represent a digitized scrapbook, a compound object might contain a series of 25 pages or photographs from a scrapbook. The parent compound object metadata record provides full details about the scrapbook, while the child object metadata records will only describe the unique information about each individual page or photo. 
    - **Oral history**: an oral history compound object might contain various derivatives of an interview, such as audio, video, transcript, and portrait.
    - **Gallery**: a gallery compound object might contain a series of images from one event that are individually described with independent metadata.

### multiple

A "multiple" item is a set of images to be displayed together in a single Item page. 

- Parent items with the display_template value (CB-CSV) or format (CB-GH) of `multiple` will generate an Item page featuring the child objects displayed as a vertical series of large images that scroll down the page. The children *do not* have individual child object pages/modals. Instead, clicking the child images will open a spotlight gallery of the images. Individual metadata for each child object is *not* displayed.
- "multiple" use case examples: 
    - **Postcard**: images of a postcard's front and back that are not individually described in the metadata beyond having a "title" value. 
    - **3D archeological artifact**: images representing standardized perspectives of an archeological artifact that are not individually described in the metadata beyond having a "title" value (for example, "top", "bottom", "side" of a bowl).
    - **Gallery**: images from a single event that are not individually described in the metadata beyond having a "title" value.

The "multiple" display_template (CB-CSV) or format (CB-GH) works well if the child files do *not* require their own metadata. By default, only the "title" of the child files will be represented on the item page -- all other metadata for child files will be ignored. 

### image_comparison

A "image_comparison" item is TWO images that are displayed together by stacking them on top of each other and providing a slider to reveal one or the other.
The layout uses [Before-After Image Comparison Slider](https://github.com/markpbaggett/before-after), a lightweight web component library for comparing two images, created by markpbaggett for TAMU Library (inspired by Knight Labs's JuxtaposeJS).
This only works with TWO image items, so you will have three rows (parent and 2 children).

- Parent item will have the "display_template" value `image_comparison`. 
    - Fill the metadata fields to describe the comparison.
    - The "object_location" column will be blank.
- The two child records will have "display_template" value `image`. 
    - Fill in the metadata fields as a normal image Item.
    - Child metadata will be displayed in a collapse.

Check the comments at the top of "_layouts/item/image_comparison.html" for front matter options that configure the layout for all "image_comparison" items. 
There are two main options: "slider" (the image comparison is the main display on the item page) or "side-by-side" (two image thumbs with button to open full screen modal with the image comparison).
