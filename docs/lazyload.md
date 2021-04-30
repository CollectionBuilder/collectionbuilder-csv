# Lazyload images

To avoid making browser load times too long, it is best to defer loading images until they are actually visible to the user. 
To do this CollectionBuilder uses [lazysizes](https://github.com/aFarkas/lazysizes) library.
Lazysizes is a simple to use, up-to-date lazyload library that requires no initialization, and will simply load all images if browser support is missing. 

Since lazysizes is used on most pages in the project, `lazysizes.min.js` is loaded as part of the default template in the foot.html include.

For images that should be lazy loaded, add `class="lazyload"` and replace normal `src` with `data-src`.
No initialization is necessary. 
