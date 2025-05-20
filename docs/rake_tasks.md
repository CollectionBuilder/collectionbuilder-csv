# Rake

[Rake](https://github.com/ruby/rake) is a task automation tool written in Ruby.
It is a standard part of all Ruby installs, so if you are using Jekyll, you have it.
Adding a "Rakefile" allows you to add commands to automate repetitive tasks.

CollectionBuilder-CSV provides a "Rakefile" with tasks to help set up and deploy your digital collection.
This allows you to run `rake` commands inside this repository.
the use of each task is documented in "docs/rake_tasks/" folder. 
The code for the individual rake tasks is contained in the folder "rakelib".

The two most commonly used task are:

## deploy

`rake deploy`, is a short cut to run the full Jekyll command `JEKYLL_ENV=production bundle exec jekyll build`.
Using the production environment causes template to include analytics and additional machine markup in build, which can take considerably longer than `jekyll s`.

## generate_derivatives

`rake generate_derivatives`, automates the creation of optimized, small and thumbnail images from all images and PDFs contained in the "objects/" directory in this repository. (Note: Optimization is not supported for Windows users.)
It outputs the derivatives to "objects/small" and "objects/thumbs".
Please ensure you have the requirements installed and available on the commandline before running!

Requirements:

- **ImageMagick**, [download](https://imagemagick.org/script/download.php)
- **Ghostscript**, [download AGPL version](https://www.ghostscript.com/download/gsdnld.html) (required for processing PDF items)

Check the doc file for full configuration options.

Note: the image_optim Gem is used to optimize images using the optimization libraries provided by the image_optim_pack Gem. 
However, image_optim_pack does not provide binaries for Windows, so optimization is skipped when using the rake task on Windows.
