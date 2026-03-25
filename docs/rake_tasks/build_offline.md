# build_offline

`rake build_offline` generates your CB site, downloads all external media, and then rewrites all internal links to create a copy of your project that can be used fully offline in the local filesystem.

The fully static offline file version is intended to serve as an artifact for digital preservation that maintains the functionality of a project in a minimal environment.
It can also be useful for sharing the site (via a thumb drive) in a location with no internet, or for content that needs to remain offline for security or privacy reasons.

The task will:

1. Complete a fresh build of the site (same as `rake deploy`)
2. Copy the build to the output directory
3. Download external media (images, PDFs, audio) references in your metadata CSV to the "objects" folder. 
4. Rewrite all links in the files to relatives file paths so that pages can load and link correctly from the local filesystem.

When the task completes, you can browse the offline version by clicking "offline_site/index.html" to open it in your web browser.

| option | description | default value |
| --- | --- | --- |
| download_external | attempt to download all external media linked in the project including items, true/false | true |
| output_dir | directory name for output offline version | "offline_site" |

Pass options as rake arguments: 

`rake build_offline[false,"my_offline_copy"]`

## Limitations

- Streaming video (YouTube, Vimeo, etc.) is not downloaded and will not play offline. Item pages for video objects will display without the video.
- External images not in metadata (e.g., organization logos in the banner) remain as external links and require internet to display. Please manually adjust those images in your project.
- DataTables on the Data page loads item data via an AJAX request to a local JSON file. Some browsers restrict local file AJAX requests by default, which may prevent the table from loading.
- Map tiles (Leaflet/OpenStreetMap) require internet access. The map page will show markers but no background tiles when offline.
