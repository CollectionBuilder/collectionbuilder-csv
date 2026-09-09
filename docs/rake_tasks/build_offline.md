# build_offline

`rake build_offline` generates your CB site, downloads all external media, and then rewrites all internal links to create a copy of your project that can be used fully offline in the local filesystem.

The fully static offline file version is intended to serve as an artifact for digital preservation that maintains the functionality of a project in a minimal environment.
It can also be useful for sharing the site (via a thumb drive) in a location with no internet, or for content that needs to remain offline for security or privacy reasons.

The task will:

1. Complete a fresh build of the site into the output directory, using the "offline" JEKYLL_ENV which swaps out some parts of the site specific to building offline.
2. Download external media (images, PDFs, audio) referenced in the "object_location", "image_small", and "image_thumb" fields of your metadata CSV into the "objects" folder of the output directory (not your project's "objects" folder). Downloaded files are named by objectid following CB conventions, e.g. "objects/small/demo_001_sm.jpg". Any download that fails is left pointing to the original external link, and a summary is written to "offline_build_log.txt" in the output directory.
3. Rewrite all internal links to relative file paths so that pages can load and link correctly from the local filesystem. 
4. Inline the SVG icon sprite into each page, since browsers block loading external SVG symbol files from the local filesystem.

When the task completes, you can browse the offline version by clicking "offline_site/index.html" to open it in your web browser.

| option | description | default value |
| --- | --- | --- |
| download_external | attempt to download all external media linked in the project including items, true/false | true |
| output_dir | directory name for output offline version | "offline_site" |
| skip_rewrite | comma separated list of directories to skip rewriting, useful for external libraries containing HTML that should not be modified. Pass an empty value (e.g. `rake build_offline[true,offline_site,]`) to rewrite everything. | the `lib-assets` value from "_config.yml", usually "assets/lib" |
| download_video | also download directly hosted video files (mp4, webm, ogv, mov) linked in metadata. These can be very large, so they are off by default. | false |

Pass options as rake arguments: 

`rake build_offline[false,"my_offline_copy","assets/lib",true]`

## Notes

The output directory is excluded from the Jekyll build automatically. If you use a custom output_dir, you may still want to add it to `exclude` in "_config.yml" and to ".gitignore" so it is not picked up by `jekyll serve` or committed to your repository.

The build uses a placeholder `baseurl`, so every path that passes through Jekyll's `relative_url` or `absolute_url` filter is marked and can be rewritten reliably in HTML, CSS, JS, and data files. Links to the site root or to directory-style permalinks (e.g. "/search/") are pointed at the "index.html" file, since browsers do not resolve directories without a server. As a fallback, hardcoded root-relative paths in HTML attributes (e.g. a markdown link written as "/browse.html") are also rewritten when they point to a file or folder in the build.

If you have external downloads fail, you may want to manually download those images and add them to your project and metadata, then re-run the task. 
Manually prepping your "objects" folder may be more failsafe than relying on the builtin download functionality in some cases.

## Limitations

- Streaming video (YouTube, Vimeo, etc.) is not downloaded and will not play offline. Item pages for video objects will display without the video, although their thumbnail images are downloaded. Directly hosted video files are only downloaded when `download_video` is true.
- Bootswatch themes and CDN fonts (`bootswatch` and `font-cdn` in "_data/theme.yml") are not available offline. The offline build always uses the local Bootstrap CSS and browser default fonts instead.
- Map tiles (Leaflet/OpenStreetMap) require internet access. The map page will show markers but no background tiles when offline.
- External images not in metadata (e.g., organization logos in the banner) remain as external links and require internet to display. Please manually adjust those images in your project.
- Paths in standalone JavaScript files (e.g. "assets/js") and in the data exports in "assets/data" are rewritten as root-relative paths (e.g. "/items/demo_001.html") rather than relative ones, because a relative path inside a script resolves against the page that loads it rather than the script itself. Keep any site links in page-specific JS includes (as CB does in "_includes/js") rather than in standalone ".js" files.
- Paths that do not pass through a Liquid url filter are only rewritten when they appear in an HTML attribute and point into the site (i.e. begin with a top-level file or folder of the build). Absolute links to other resources on the site's own domain are left as external links.
- The rewrite script is idiosyncratic to CB projects, so may not work correctly for other websites or highly customized projects. A unit test for the rewrite rules can be run with `ruby rakelib/test/offline_rewrite_test.rb`.

