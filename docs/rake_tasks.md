# Rake

[Rake](https://github.com/ruby/rake) is a task automation tool written in Ruby.
It is a standard part of all Ruby installs, so if you are using Jekyll, you have it.
Adding a "Rakefile" allows you to add commands to automate repetitive tasks.

CollectionBuilder-CSV provides a "Rakefile" with tasks to help set up and deploy your digital collection.
This allows you to run `rake` commands inside this repository:

## deploy

`rake deploy`, is a short cut to run the full Jekyll command `JEKYLL_ENV=production bundle exec jekyll build`.
Using the production environment causes template to include analytics and additional machine markup in build, which can take considerably longer than `jekyll s`.

## generate_derivatives

`rake generate_derivatives`, automates the creation of optimized, small and thumbnail images from all images and PDFs contained in the "objects/" directory in this repository. (Note: Optimization is not supported for Windows users.)
It outputs the derivatives to "objects/small" and "objects/thumbs".
Please ensure you have the requirements installed and available on the commandline before running!

Requirements:

- **ImageMagick**, [download](https://imagemagick.org/script/download.php)
- **Ghostscript**, [download AGPL version](https://www.ghostscript.com/download/gsdnld.html)

The following configuration options are available:

| option | description | default value |
| --- | --- | --- |
| thumbs_size | the dimensions of the generated thumbnail images | 300x300 |
| small_size | the dimensions of the generated small images | 800x800 |
| density | the pixel density used to generate PDF thumbnails | 300 |
| missing | whether to only generate derivatives that don't already exist | true |
| compress_originals | Optimize the original image files | false |

You can configure any or all of these options by specifying them in the rake command like so:

```
rake generate_derivatives[<thumb_size>,<small_size>,<density>,<missing>,<compress_originals>]
```

Here's an example of overriding all of the option values:

```
rake generate_derivatives[100x100,300x300,70,false,false]
```

It's also possible to specify individual options that you want to override, leaving the others at their defaults.
For example, if you only wanted to set `density` to `70`, you can do:

```
rake generate_derivatives[,,70]
```

The mini_magick Gem is used to interface with ImageMagick so it supports both current version 7 and legacy versions (which are common on Linux). 
The image_optim Gem is used to optimize images using the optimization libraries provided by the image_optim_pack Gem. 
image_optim_pack does not provide binaries for Windows, so optimization is skipped when using the rake task on Windows.
