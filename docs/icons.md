# Icons

The template includes [Bootstrap Icons](https://icons.getbootstrap.com/) 1.5.0 for use in pages. 
The full icon set is in "assets/lib/icons".

## Full Bootstrap SVG Sprites

It is set up to use the SVG Sprite with external file method (svg + `use`), which is efficient for users and relatively easy to use (however is NOT supported in older versions of Internet Explorer). 
Use is similar an icon font, but is more efficient and icons can scale to any size.
The external svg file will only be loaded once by the browser, then cached and used to load icons through out the site, which makes it more efficient than loading individual svg as images or inlining the svg.

The pattern to use the full Bootstrap SVG Sprite set looks like this:

```
<svg class="bi icon-sprite" aria-hidden="true">
    <use xlink:href="{{ site.lib-assets | default: '/assets/lib' | relative_url }}/icons/bootstrap-icons.svg#arrow-up-square" href="{{ site.lib-assets | default: '/assets/lib' | relative_url }}/icons/bootstrap-icons.svg#arrow-up-square"></use>
</svg>
<span class="visually-hidden">Up Arrow</span>
```

The `xlink:href` is the link to the icons file (all icons are includes in the file "/assets/lib/icons/bootstrap-icons.svg"), plus `#` plus the id of the icon you want to use. 
Find the id/names of all icons on the [Bootstrap Icons](https://icons.getbootstrap.com/) page.

Styles to make the sprites work are in `_sass/_base.scss`. 
The `.bi` class applies to all the sprite icons generally to set some useful defaults, including add `fill: currentColor` so that the icon will follow the parent's text color.
The `.icon-sprite` class adds a width and height of `1em` which allows the icon to be used like a font character (when combined with the `bi` styles).
These are kept separate for instances when you might want to use the icon like an image with a percentage width or other sizing method.

If the icon is used to convey meaning, you should use `aria-label=` or `<span class="visually-hidden">` to add an alternative for icon as sibling of svg.
The svg element should have `aria-hidden="true"` added to avoid issues with the content being read twice on screen readers. 

The icon-sprite style icons can be added using the feature/icon.html include, 
e.g. `{% include feature/icon.html icon="file-play" label="Audio file" %}`.
This include can add icons anywhere, including inline in Markdown content.

To use an icon similar to an image (for example as an icon stand in for thumbnails on Browse or Timeline), follow the pattern:

```
<svg class="bi w-50 text-body" fill="currentColor" aria-hidden="true">
    <use xlink:href="{{ site.lib-assets | default: '/assets/lib' | relative_url }}/icons/bootstrap-icons.svg#file-earmark-play"/>
</svg>
<span class="visually-hidden">File icon</span>
```

In this example, the classes on the svg element control the size and color: 

- `w-50` to set the svg to be 50% of the parent space. This makes it easy to create responsive icons if the svg element is inside a column div.
- `text-body` to set the color. Any BS text color utility can be used, including your custom color theme classes.

## Theme Icons

CollectionBuilder-CSV uses a small set of icons for fall back thumbnails for items that do no have images available. 
If a template page is looking for `image_small` or `image_thumb` and finds it blank, it will choose an icon replacement based on `display_template` or `format` fields (on Browse, Map, Timeline, and Item pages).
Theme icons are also used for the "back to top" button.

During Jekyll's build process, CollectionBuilder's "cb_helpers" plugin processes the icons and adds them to `site.data.theme_icons`. 
The theme icons are added to a SVG Sprite file "/assets/css/cb-icons.svg" (which is much smaller and customized compared to "bootstrap-icons.svg").

Configuring the theme icons is *optional*. 
If desired, the default icons can be overridden or new icons can be added using the `icons` object in "_data/theme.yml". 
The default values look like:

```
icons: 
  icon-image: image
  icon-audio: soundwave
  icon-video: film
  icon-pdf: file-pdf
  icon-record: file-text
  icon-panorama: image-alt
  icon-compound-object: collection 
  icon-multiple: postcard
  icon-default: file-earmark # fall back icon
  icon-back-to-top: arrow-up-square
```

The icon key (e.g. `icon-image`) will become the id of the SVG sprite symbol. 
The value must match a Bootstrap icon svg found in "assets/lib/icons/" folder.
Adding new keys will add additional icons to the SVG sprite file.

All theme icons configured in `icons` (plus the default ones) can be used in several ways:

- To add a full svg inline, use the Liquid variable `site.data.theme_icons` plus the icon key plus `.inline`. E.g. `{{ site.data.theme_icons.icon-image.inline }}`.
- To add an icon svg sprite symbol, use the Liquid variable  `site.data.theme_icons` plus the icon key plus `.symbol`. E.g. `{{ site.data.theme_icons.icon-image.symbol }}`.
- Use the external svg sprite link markup using with href to the "cb-icons.svg" file and hash for the icon key. E.g. `<svg class="bi text-body" fill="currentColor"><use xlink:href="{{ "/assets/css/cb-icons.svg" | relative_url }}#icon-image"/></svg>`

The "cb_helpers" plugin contains built in SVGs for the default icon options.
This means if you are not customizing the icons or using feature/icon.html include, the "assets/lib/icons/" folder can be removed if desired.
