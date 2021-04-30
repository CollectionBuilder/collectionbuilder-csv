# Rake 

[Rake](https://github.com/ruby/rake) is a task automation tool written in Ruby. 
It is a standard part of all Ruby installs, so if you are using Jekyll, you have it.
Adding a `Rakefile` allows you to add commands to automate repetitive tasks.

CollectionBuilder-SA provides a `Rakefile` with tasks to help set up and deploy your digital collection. 
This allows you to run `rake` commands inside this repository: 

## deploy

`rake deploy`, runs Jekyll command `JEKYLL_ENV=production jekyll build` which includes analytics and additional machine markup in build. 
Production build will take considerably longer than `jekyll s`. 

## generate_derivatives

`rake generate_derivatives`, automates creating a small and thumb image from all images and PDFs contained within the "objects/" directory in this repository. 
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
| im_executable | ImageMagick executable name | magick |

You can configure any or all of these options by specifying them in the rake command like so:

```
rake generate_derivatives[<thumb_size>,<small_size>,<density>,<missing>]
```

Here's an example of overriding all of the option values:

```
rake generate_derivatives[100x100,300x300,70,false]
```

It's also possible to specify individual options that you want to override, leaving the others at their defaults.
For example, if you only wanted to set `density` to `70`, you can do:

```
rake generate_derivatives[,,70]
```

The task assumes you are using ImageMagick 7. 
If you have legacy ImageMagick (i.e. 6), which is common from Linux repositories, you need to set the `im_executable` configuration option to `convert`:

```
rake generate_derivatives[,,,,convert]
```
