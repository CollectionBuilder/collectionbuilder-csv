# Icons

The template includes [Bootstrap Icons](https://icons.getbootstrap.com/) for use in pages. 

It is set up to use the SVG Sprite with external file method (svg + `use`), which is efficient for users and relatively easy to use (however is NOT supported in older versions of Internet Explorer). 
Use is similar an icon font, but is more efficient and icons can scale to any size.
The external svg file will only be loaded once by the browser, then cached and used to load icons through out the site, which makes it more efficient than loading individual svg as images or inlining the svg.

The pattern to use SVG Sprite looks like this:

```
<svg class="bi icon-sprite" aria-hidden="true">
    <use xlink:href="{{ '/assets/lib/bootstrap-icons.svg' | relative_url }}#arrow-up-square" href="{{ '/assets/lib/bootstrap-icons.svg' | relative_url }}#arrow-up-square"></use>
</svg>
<span class="sr-only">Up Arrow</span>
```

The `xlink:href` is the link to the icons file (all icons are includes in the file `/assets/lib/bootstrap-icons.svg`), plus `#` plus the id of the icon you want to use. 
Find the id/names of all icons on the [Bootstrap Icons](https://icons.getbootstrap.com/) page.

Styles to make the sprites work are in `_sass/_base.scss`. 
The `.bi` class applies to all the sprite icons generally to set some useful defaults, including add `fill: currentColor` so that the icon will follow the parent's text color.
The `.icon-sprite` class adds a width and height of `1em` which allows the icon to be used like a font character (when combined with the `bi` styles).
These are kept separate for instances when you might want to use the icon like an image with a percentage width or other sizing method.

If the icon is used to convey meaning, you should use `<span class="sr-only">` to add an alternative for icon as sibling of svg.
The svg element should have `aria-hidden="true"` added to avoid issues with the content being read twice on screen readers. 

The icon-sprite style icons can be added using the feature/icon.html include, 
e.g. `{% include feature/icon.html icon="file-play" label="Audio file" %}`.

To use an icon similar to an image (for example as an icon stand in for thumbnails on Browse or Timeline), follow the pattern:

```
<svg class="bi w-50 text-body" fill="currentColor" aria-hidden="true">
    <use xlink:href="{{ '/assets/lib/bootstrap-icons.svg' | relative_url }}#file-earmark-play"/>
</svg>
<span class="sr-only">File icon</span>
```

In this example, the classes on the svg element control the size and color: 

- `w-50` to set the svg to be 50% of the parent space. This makes it easy to create responsive icons if the svg element is inside a column div.
- `text-body` to set the color. Any BS text color utility can be used, including your custom color theme classes.
