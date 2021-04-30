# Rich markup

Pages in CollectionBuilder contain machine readable rich markup following several standards to improve discoverability, search representation, and social media sharing.

## Dublin Core 

Dublin Core elements are added to Item pages driven by the "dc_map" column of config-metadata.csv.

Choose mapping options directly from the DCMI Terms namespace: http://purl.org/dc/terms/
*Note: DMCI the original 15 Elements namespace is mirrored in the Terms namespace (i.e. both have "title", "creator", etc), however, using the newer Terms namespace is preferred.*

The values will be directly added to meta tag name attribute, thus should use the `DCTERMS` prefix.

For example, to use Dublin Core [Title](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#http://purl.org/dc/terms/title) from the "Terms" namespace, the value would be `DCTERMS.title`.
To use [abstract](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#http://purl.org/dc/terms/abstract), `DCTERMS.abstract`.
If the "dc_map" column is empty, no DC meta tags will be added.

Recommended fields to map include:

- `DCTERMS.title`
- `DCTERMS.creator`
- `DCTERMS.created` or `DCTERMS.date`
- `DCTERMS.description`
- `DCTERMS.subject`
- `DCTERMS.type`

This implementation is based on DSpace, following the [DC-HTML](https://www.dublincore.org/specifications/dublin-core/dc-html/2008-08-04/) conventions.

## Open Graph Protocol

[Open Graph](https://opengraphprotocol.org/) provides basic metadata in a open standard used by social media sites to generate representations of links shared on the platform.
Open Graph was established by Facebook, but can be read by other platforms.

OG meta tags are automatically added to every page and are not configurable.
They provide an authoritative title, description, and image that can be used to represent a link to the page.
The OG image will be the item image/thumb in the case of item pages, or the site featured image for all other pages.
For example:

`<meta property="og:title" content="{{ page.title | escape }}" />`

## Schema.org 

Schema is a standard designed to provide structured semantic markup for search engines to better understand content of web pages. 
The concepts described apply to a generalized web landscape, centered mostly around commercial sites, and don't necessarily follow the logic and structure of library-based metadata or digital collections.
However, it is useful to provide the markup to drive better representations of the data in search results.
See [Full Schema hierarchy](https://schema.org/docs/full.html), or [Google Guide to Structure Data](https://developers.google.com/search/docs/guides/intro-structured-data).

Keep in mind that Schema is an open standard, however, Google is the biggest consumer, so information found in Google's [Developer Docs](https://developers.google.com/) is potentially more pragmatically useful (e.g. Google highly recommends using JSON-LD vs. Schema suggesting microdata).
Markup can be tested using Google's [Structured Data Testing Tool](https://search.google.com/structured-data/testing-tool).

The Schema markup is different on a variety of page types:

### Item pages 

Item pages have in depth Schema markup in JSON-LD format driven by the object metadata. 
Schema elements are driven by the "schema_map" column of config-metadata.csv.
Each item page is given the basic type of `CreativeWork`, thus metadata fields can be mapped to any of the properties listed on the [CreativeWork documentation](https://schema.org/CreativeWork). 
Copy the exact property name, as this value will be turned into schema JSON-LD markup.
If the "schema_map" column is empty, only the automatically generated markup will be added.

Suggested field mappings include:

- `headline` (i.e. the title)
- `creator`
- `dateCreated`
- `description`
- `keywords`
- `contentLocation`
- `encodingFormat` (MIME type, should = format field of CollectionBuilder items)
- `license` (should only be used with a standardized rights URL)

Additionally, the Schema type, `isPartOf` (the collection), `image` (url), `thumbnailUrl` (url), and page `url` will be added automatically. 

Note: in the future, our base item type may move to `ArchiveComponent` when this spec is fully integrated into the standard, https://schema.org/ArchiveComponent .
An alternative approach would be to use `ItemPage`, https://schema.org/ItemPage to describe the object pages, although this seems less direct.

Item pages are also marked up with Schema [BreadcrumbList](https://schema.org/BreadcrumbList) to represent their nesting in the site, which may be [represented in search results](https://developers.google.com/search/docs/data-types/breadcrumb). 

### Data page

The Data page includes Schema markup in JSON-LD representing the various data derivatives that can be downloaded (implemented in _includes/data-download-modal.html which is included by the data layout). 
See [Google dataset docs](https://developers.google.com/search/docs/data-types/dataset) and [Schema Dataset](https://schema.org/Dataset) for details behind this implementation.

The full metadata download in csv and json are automatically added.
A metadata facets json file is added if fields are set in theme "metadata-facets-fields".
Additional datasets described are selected based on what pages are in the config-nav, following the same logic used to select which data download buttons are shown to users.
If the config-nav contains the following "stub", the following data files will be added to the markup:

- "subject", subjects.csv, json
- "location", locations.csv, json
- "map", geodata.json
- "timeline", timelinejs.json

This may not be accurate for all use cases. 
An easy way to manually set the downloads, is to create a list based on the stub values shown above, and edit the "stubs" assigned on the data.html layout. 
For example, if I want to show all data downloads, even though I don't have the pages in the navigation or have named them something different, edit the "assign stubs" line on data.html like this:

`{%- assign stubs = "subject;map;location;timeline" -%}`

Also check docs/data.md for more information.

### Content pages

Other pages in the site receive more basic markup from the head/page-meta.html include following the [WebPage schema type](https://schema.org/WebPage).
