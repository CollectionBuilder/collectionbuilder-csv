# Gallery viewer

Powered by lightGallery, http://sachinchoolur.github.io/lightGallery/

Used to add full screen view to item pages, potentially with support for multiple images or for browse (not currently implemented, for example see items in [HJCCC](https://www.lib.uidaho.edu/digital/hjccc/)).

Add assets and basic initialization to any page by adding front matter `gallery: true`. 

The page requires:

- one `div` with with `id="lightgallery"` containing the gallery items.
- a `div` around each individual image with `class="gallery-img"` plus `data-src=` with the link to higher quality image.

This is currently automatically added to item pages for objects with images.
