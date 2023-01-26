# Compound Objects

"Compound objects" are a concept used in some repository platforms to describe items that are made up of a set of digital files intended to be treated as one singular connected record in the system.
CollectionBuilder has built in item page templates for displaying compound objects that are represented in your metadata.
This is similar to choosing a "display_template" value for your records (see "docs/item_pages.md"), however, because compound objects require some additional metadata conventions, the details are described here.

## Quick Overview + Requirements

Compound objects can be added to CollectionBuilder following these conventions in your metadata:

- A "parentid" column must be present in your metadata spreadsheet/csv. The "parentid" will be empty for all normal items. 
- A parent metadata record must be created for each compound object with a display_template value of either `compound_object` or `multiple`. 
    - a `compound_object` will display a grid of collected items (of any accepted CB type) whose metadata and media can be viewed in a series of browsable modals
    - a `multiple` is image based and will display a vertical series of larger images that scroll down the page
- The parent metadata record requires an objectid but no parentid.
- Each child record must have an objectid AND a parentid.
- Each child record's parentid value must match the parent metadata record's `objectid` 
    - e.g. If the parent's objectid is example002, then all children for have "example002" in their parentid field

Please look at the demo compound object metadata sheet for an example of how this might look in the metadata: <https://docs.google.com/spreadsheets/d/1UNwl02r3fB-ybiKqb3SY4K30Tf4_rY_NOv5_o5WtVoY/edit?usp=sharing>, and see the demo CollectionBuilder-CSV site for how this looks in operation. 

## Context 

There are two main approaches to representing these types of objects in a CollectionBuilder project. These correspond to the display templates "compound_object" and "multiple." 

A `compound_object` can include any type of media that CollectionBuilder handles, i.e. image, pdf, video, audio, panorama, or record. A `multiple` should be image based, and is best used for items such as postcards or multi-view records of a 3-dimensional object. These items will display as such: 

- Those items with the display_template of `compound_object` will display as a grid of cards featuring item thumbnails that, upon being clicked, will open a child object page as a modal. 
- Those items with the display_template of `multiple` will display as larger small images that *do not* have child object pages. If one clicks on one of these larger images, they will open up in a zoomable spotlight gallery.

**Note:** The "multiple" display template works well if the additional files do *not* require their own extensive metadata. Our build will only represent the "title" of the child elements on the item page -- all other metadata for child objects with the display_template postcard will be ignored. 

### `compound_object` Examples

- Scrapbook: for a digitized book the "compound object" might contain a series of 25 individual page images. The parent metadata record provides full details about the book, while the child metadata records will only describe the unique information about each page such as a transcript.
- Oral history: each object might contain different derivatives of an interview, audio, video, transcript, and portrait.
- Gallery: a gallery of images from one event that are individually described

### `multiple` Examples

- Postcard: usually a compound object containing a front and back image. 
- 3D archeological artifact: archeological objects are often imaged from standardized perspectives to provide experts information about the piece.
- Gallery: a gallery of images from one event that are not individually described
 
## parentid

Our approach for describing "compound objects" and "multiples" require a top level metadata record describing the object overall (the parent). As such, these items diplays depends on the parentid field, which connects child metadata record(s) that describe the individual related files to the parent record. 
This allows each child object to be fully described individually (or not) using your full metadata template.
It is also useful if you are exporting existing metadata from a platform such as CONTENTdm with "page level" metadata.

These are the basic conventions:

- The child record(s) must have a "parentid" that matches the "objectid" of their parent.
- Both the parent and the child must have an "objectid".
- The parent should have a "display_template" of "compound_object" or "multiple" to use the respective display templates.
- Child records should have their own "display_template" to help choose the appropriate features on the item page. (i.e. use "image" for a .JPG file)
- The image listed in image_thumb and image_small of the parent will be used to represent the item in all visualizations.
- You can use the Compound Objects options in the theme page to determine if you would like your compound objects to show up in the timeline, map, or browse pages.
- Default visualizations (except the item page) use *only* the parent record, so child records are not searchable on the browse page of search page.
