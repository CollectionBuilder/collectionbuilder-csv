# Foot Section

All JS is loaded at the bottom of the page in "foot.html" include.
This ensures JS libraries are loaded in correct order and are optimized for page load.

First, "foot.html" adds bootstrap bundle and lazysizes assets which are required on all pages. 
Next, any other chunks of JS are added via includes based on the page layout or front matter options.

Most default CB layouts have a custom JS component specific to the visualization.
In general, these are added to the page using the `custom-foot` option in the layout's front matter.

## custom-foot Option

To add an include to any page or layout, use the `custom-foot` option in the yml front matter. 

Create the include in the "_includes" folder, then provide the filename in the `custom-foot` value.
Multiple includes can be added separated by a semicolon `;`.

### custom-foot Example

You want to add some custom JS to "pages/about.md".

Create the includes "_includes/js/example.html" and "_includes/js/another_example.html" with the module component parts. 
The JS will be written in the includes inside of `<script>` tags, as if it is an html file.

In the file "pages/about.md", add the front matter option `custom-foot: js/example.html;js/another_example.html`.
The resulting front matter might look like:

```
---
title: About
layout: about
permalink: /about.html
custom-foot: js/example.html;js/another_example.html
---
```

The two includes will be added by "foot.html", after bootstrap js is loaded.
