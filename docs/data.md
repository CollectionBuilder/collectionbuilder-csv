# Data export

CollectionBuilder uses Jekyll to generate specialized derivatives of your metadata to consume for visualizations and to expose for others to download.

Data used by the website and available for download is in the `/assets/data/` directory.

Data used by the visualizations is usually specialized and optimized for page load, thus limited to the exact fields and information used by the specific page consuming it.
These derivatives are often written directly into the HTML pages for faster load time.

Since this data is not easy to understand or reuse, CollectionBuilder also generates more complete versions for others (and yourself) to consume. 

The `/assets/data/metadata.csv`, `/assets/data/metadata.json`, and `/assets/data/geodata.json` data downloads are driven by the `site.data.theme.metadata-export-fields`. 
This means the CSV/JSON download can be more complete, containing more fields than are displayed anywhere on the site.

Other data derivatives are provided to explore and quantify collection content.
`facets.json` can summarize the unique value counts of metadata fields. 
The fields evaluated by `facets.json` is configured using `site.data.theme.metadata-facets-fields`.
The `subjects.json`, `subjects.csv`, `locations.csv` and `locations.json` use the same routine to generate commonly used facets, plus links to the collection's browse page to explore them.
The fields used are configured in `site.data.theme.subjects-fields` and `site.data.theme.locations-fields`.

`timelinejs.json` is a time-focused format designed to work with the standalone version of Knight Lab's [TimelineJS](http://timeline.knightlab.com/).

A link to the source code repository will be included if `source-code` is set in _config.yml, otherwise it will link to CollectionBuilder.

## Data Markup

The data found in `/assets/data/` can be seen as a "datapackage" containing all the derivatives related to the collection.
This data is described by two markup standards. 

First, the Data page (`/data.html`) contains [schema.org Dataset](https://schema.org/Dataset) markup embedded on the page in json+ld format (written in the `_includes/data-download-modal.html` file). 
This markup is [required by Google](https://developers.google.com/search/docs/data-types/dataset) to be indexed into their datasets search engine. 

Second, `/assets/data/` contains `datapackage.json` as described by the Frictionless Data [Data Package Spec](https://specs.frictionlessdata.io/data-package/).
Each data file "resource" is described following the [Data Resource Spec](https://specs.frictionlessdata.io/data-resource/).

Both methods provide metadata about the collection and a list of all downloadable data formats, documenting the data for better reuse and preservation.

## Data download logic

The data downloads displayed on the Data page, on the home page "Collections as Data" box, and in the data markup schemas is based on which pages are present in `config-nav.csv` "stub" field. 
If stubs contain "subject", "location", "map", and/or "timeline" the corresponding data formats will be displayed for download and included in the markup.
If you change the default name of the stubs, or use the default pages for different content, this logic may display the incorrect set of data. 
Please manually check over `_includes/data-download-modal.html`, `_includes/index/data-download.html` and `assets/data/datapackage.json` to select the correct files.

See docs/markup.md for additional information.
