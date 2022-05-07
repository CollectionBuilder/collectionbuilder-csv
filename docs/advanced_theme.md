# Advanced theme options

`theme.yml` includes some advanced theme options to make it easy to customize the look and standard colors.
Additionally, see "color-theme.md" for information about automatic theming Bootstrap color classes for buttons, text, and backgrounds.

## Navbar colors

By modifying `navbar-color` and `navbar-background` the basic colors of the navigation elements can be switched following Bootstrap theme colors (see [Bootstrap navbar docs](https://getbootstrap.com/docs/5.1/components/navbar/)).

- `navbar-color`: either navbar-light" for use with light background colors, or "navbar-dark" for dark background colors
- `navbar-background`: choose from standard Bootstrap color utilities, bg-primary, bg-secondary, bg-success, bg-danger, bg-warning, bg-info, bg-light, bg-dark, or bg-white

## Bootswatch option

To play with more Bootstrap theme-ing, try swapping out a [Bootswatch](https://github.com/thomaspark/bootswatch) favor. 
This will remove default Bootstrap CSS for the Bootswatch version (from a CDN), swiftly changing the entire look.
Choose from: cerulean; cosmo; cyborg; darkly; flatly; journal; litera; lumen; lux; materia; minty; pulse; sandstone; simplex; sketchy; slate; solar; spacelab; superhero; united; yeti.

This is mainly just a fun way to demonstrate the power of CSS and frameworks to transform look and feel. 

## Theme fonts 

To tweak the default font and text colors check the "Theme fonts" section.
These setting will be passed to `/assets/css/custom.scss` which in turn passes the values to the `_sass` to build out the final CSS. 

- `base-font-size` we set font size a bit bigger than Bootstrap default, which can be tweaked here.
- `text-color` we set the base color to a darker black.
- `link-color` by default set to match Bootstrap "info". This is an easy way to add a distinctive brand color to your site.
- `base-font-family` sets the font-family for `body`, overriding Bootstrap. It will be necessary to use `font-cdn` or manually add loading the font in the head element (_includes/head/head.html). 
- `font-cdn` will add a font stylesheet, such as from [Google Fonts](https://fonts.google.com/), to the head element. Use valid markup, e.g. `<link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" rel="stylesheet">`. Keep in mind, these CDN expose your users to a 3rd party service and trackers.
