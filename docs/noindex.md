# Robots and Indexing

If you are building a demo or prototype collection you may want to avoid having the content indexed by Google and other search engines. 
This can be done using a Robots.txt at the root level of the site, or a [robots meta tag](https://developers.google.com/search/reference/robots_meta_tag) on each page. 
To make adding robots meta tag easy, CollectionBuilder includes the option to add it across the project or to individual pages:

- full site, uncomment or add `noindex: true` to "_config.yml". 
- individual page or layout, add `noindex: true` to the YML front matter.

This will cause `<meta name="robots" content="noindex" />` to be added to the page(s) head during production build. 
