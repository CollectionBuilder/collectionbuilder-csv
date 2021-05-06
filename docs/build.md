# Building your Collection

## Developing Locally 

Before serving/building your project for the **first time**, open terminal in the repository root and run `bundle install`. 
The Gem "bundler" will manage dependencies based on the project's "Gemfile", and generate a new "Gemfile.lock" with the full list of dependencies being used.
From then on, you will use `bundle exec` to prefix Jekyll commands to ensure you are using the bundled dependencies.

When developing the collection locally, use `bundle exec jekyll s` to start the development server.
Jekyll will serve the site at the local host url so the links will look like `http://127.0.0.1:4000/demo/psychiana/`.

In the background, Jekyll generates the site and outputs the files to the "_site" directory in your project repository.
Ruby provides a development server from that location.

By default the Jekyll environment is "development" when using `jekyll s`. 
In this environment CollectionBuilder skips some template elements to cut down on build time, including these `_includes`:

- head/item-meta
- head/page-meta
- head/analytics

## Building for Deployment 

To deploy the collection on the live web, you will need to use the Jekyll environment variable "production" and the `build` command rather than serve. 

This is set by adding the env variable, `JEKYLL_ENV=production`, in front of the command: 

`JEKYLL_ENV=production bundle exec jekyll build`

To simplify, this command is added in a [Rake](https://github.com/ruby/rake) task in this repository.
Typing the command `rake deploy` will set the correct environment and build. 
You will get an error if you have not previously done `bundle install` for the project.
(*note:* setting ENV cannot be done on windows CMD, use the rake task or Git Bash terminal)

Jekyll will output the site files to the "_site" directory. 
Everything in "_site" should be copied over to your web server into the correct file location depending on what you set in "_config.yml" as the `baseurl`.

*Note:* Since the extra elements are included during "production", the build time will be *significantly* higher than when using the development server.
During production build, Jekyll will generate `relative_url` and `absolute_url` using the `url` and `baseurl` values set in _config.yml. 
Keep in mind that because CollectionBuilder makes use of `absolute_url` for many assets and links, the site built using `rake deploy` will only work correctly if it is copied to the correct location on your web server.
It will not work in the "_site" folder, since the links point to locations on your server.
