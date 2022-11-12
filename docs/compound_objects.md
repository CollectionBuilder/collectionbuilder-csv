# Compound Objects

## Quick Overview Requirements

To enable compound objects in CollectionBuilder, you will need: 

- a "parent" metadata record for the compound object
- child metadata record(s) for the objects that connect in the compound object
- a "parentid" field in your metadata

And these parameters must be followed: 

- The parent metadata record should have a display template of `compound_object` or `postcard`. 
- Each child record should have a parentid value that matches the parent metadata records objectid.

Please look at the demo compound object metadata sheet for an example of how this might look: <https://docs.google.com/spreadsheets/d/1UNwl02r3fB-ybiKqb3SY4K30Tf4_rY_NOv5_o5WtVoY/edit?usp=sharing>

## Context

"Compound objects" are a concept used in some repository platforms to describe items that are made up of a set of digital files intended to be treated as one singular connected object in the system. 

For example, consider these item types:

- Book: for a digitized book the "compound object" might contain a series of 25 individual page images. The parent metadata record provides full details about the book, while the child metadata records will only describe the unique information about each page such as a transcript.
- Postcard: usually a compound object containing a front and back image. 
- 3D archeological artifact: archeological objects are often imaged from standardized perspectives to provide experts information about the piece.
- Oral history: each object might contain different derivatives of an interview, audio, video, transcript, and portrait.

There are multiple approaches to representing these types of objects in a CollectionBuilder project.
Which approach you choose will depend on the source of metadata, needs of the materials, and aims of the exhibit.

## Parentid

A powerful option for describing "compound objects" is built into CollectionBuilder-CSV.
In this approach, a top level metadata record describes the object overall (the parent), while child metadata record(s) describe the individual related files.
This allows each child object to be fully described individually (or not) using your full metadata template.
It is also useful if you are exporting existing metadata from a platform such as CONTENTdm with "page level" metadata.

However, because the spreadsheet will contain two different types of records represented in the same template, it can sometimes be more cumbersome to implement and manage.
If you are transforming existing data or have relatively simple compound object types, you might want to consider the other options outlined below this section.

These are the basic conventions:

- The child record(s) must have a "parentid" that matches the "objectid" of their parent.
- Both the parent and the child must have an "objectid".
- The parent should have "display_template" of "compound_object" to use the built-in CB compound object template.
- Child records should have their own "display_template" to help choose the appropriate features on the item page. (i.e. use "image" for a .JPG file)
- The image listed in image_thumb and image_small of the parent will be used to represent the item in all visualizations.
- You can use the Compound Objects options in the theme page to determine if you would like your compound objects to show up in the timeline, map, or browse pages.
- Default visualizations (except the item page) use *only* the parent record, so child records are not searchable on the browse page of search page.

## Simple Compound Objects / aka Postcards

The default display of compound objects in CollectionBuilder consists of a grid of thumbnails with a shortened title and an "Item Info" button that opens up a modal with the child item's information. If you would prefer to display larger versions of the children in your compound object, you should use the display template `postcard`. 

This approach works well if the additional files do *not* require their own extensive metadata, which is why the "postcard" moniker is used. Our build will only represent the "title" of the child elements on the item page -- all other metadata for child objects with the display_template postcard will be ignored. 

Objects with multiple derivatives or standardized image sets might also be well served by this simple approach to avoid confusion and overhead describing different formats available for download/view.

For example, a collection consisting mostly of postcards can be quickly implemented following this method. 
The main image fields would represent the front of the postcard, with an additional column added for the "image_back" (or what ever your organization terms it). 
The "object_location" could be the link to a PDF version of the complete post card.
Create a new "postcard" item template in "_layouts/item" (likely based on the standard "image" template) that displays the "image_back".

3D archeological artifacts with a set of standard images for each object might also be implemented in this way to avoid the overhead of many addition empty metadata rows with repeating view names.

## Separate Objects + Images List

Another approach that has been implemented for large collections of compound images, is to describe the parent "objects" in a standard metadata template, plus describe each individual image in a separate spreadsheet (in their own template). 
On the item layout, the template will use the objectid to check the image list to find the related child images to display. 

CollectionBuilder doesn't do this though. Evan did it once, so he mentioned it in the docs. 