# Jekyll Plugins

Jekyll is designed to be extensible via [Plugins](https://jekyllrb.com/docs/plugins/) written in Ruby.
The simplest method is to add Plugins directly to the `_plugins` directory, making them a part of the project repository (rather than an external Gem).
The plugins are Ruby code and run immediately as Jekyll starts.

CollectionBuilder-CSV currently uses two custom plugins "CollectionBuilder Page Generator" (`cb_page_gen.rb`) and "Array Count Uniq" (`array_count_uniq.rb`).

Keep in mind that plugins can not be used on GitHub Pages default build (although they *can* be used by setting up a GitHub Actions based build process).
Thus, collectionbuilder-gh uses fairly slow and complicated Liquid and Javascript to generate items pages and unique counts from metadata.
Those methods are not efficient enough to handle larger collections.

## CollectionBuilder Page Generator

"CollectionBuilder Page Generator" (`cb_page_gen.rb`) creates individual html pages from each record in your metadata CSV (or other _data files). 
I.e. it generates Item pages for your collection driven directly from your metadata.
It can also generate all sort of other pages from any data file.

Basic use following CB conventions requires no configuration. 
CB Page Gen will automatically generate pages from the data specified by _config.yml `metadata`.

Alternatively, for more advanced use you can provide one or more configurations in the `page_gen` option in _config.yml. 
The full options with the default values look like:

```
page_gen:
  - data: 'metadata'
    template: 'item'
    object_template: 'object_template'
    name: 'objectid'
    dir: 'items'
    extension: 'html' 
    filter: nil
    filter_condition: nil
```

At minimum, a configuration must include a `data` value. 
For example, to generate pages with the default values from three different data files would look like:

```
page_gen:
  - data: 'metadata_one'
  - data: 'metadata_two'
  - data: 'metadata_three'
```

For another example, to generate default Items pages from metadata, plus a set of "glossary" pages with non-standard configuration:

```
page_gen:
  - data: 'object_metadata'
  - data: 'collection_glossary'
    template: 'terms'
    name: 'slug'
    dir: 'glossary'
```

Full configuration options:

| option | use | default | notes |
| --- | --- | --- | -- |
| data | A file from _data to use to generate pages | `metadata` | A valid data file is required. Plugin warns if there is no match in _data and skips generation. |
| template | Set the default layout to use for pages from _layouts | `item` | The default layout must exist. Plugin warns if there is no match in _layouts and skips generation. |
| object_template | Optionally set layout using a value from the individual record data, allowing you to have different layouts for each page. | `object_template` | Record values must match a valid layout. Fallback is to template value. |
| name | The value from each record to use for output filename base (no extension). | `objectid` | A valid filename is required. Plugin skips record generation if value is blank or empty. Filenames are sanitized using Jekyll's `slugify` filter in pretty mode. CB pages assume objectid will be used for the name to create links between visualizations and item pages. |
| dir | Folder to output the pages in _site. | `items` | The dir + name + extension will control the URL of the generated pages. For example, defaults items + objectid + .html will result in link something like "/items/demo_001.html". |
| extension | File type to output, will generally be html. | `html` |  | 
| filter | A data value to filter records on. If the record has an empty value, it will not be generated. | `objectid` | Since CB templates assume a valid objectid for every item in the collection to create links across the site, the records are filtered by objectid by default. |
| filter_condition | A Ruby expression to filter data. | `nil` | |

Note: defaults are set for *all* configuration options, so none are technically required when providing a config.
If none is provided, they will fallback to the default.
If an option is invalid, the plugin will usually catch it and provide an error message.
Configuration issues and metadata errors will not interrupt normal Jekyll build process, however your site may not have item pages generated.
Please check the terminal output for notices and errors from cb_page_gen.

Filenames are created from the "name" option, which is a key in the data (i.e. a column in the csv).
File extension (generally .html) is added during the process.
The value in "name" is sanitized using the Jekyll filter slugify in "pretty" mode--this will downcase, replace all spaces and invalid url characters with `-`.
This is important to ensure valid links and filenames across platforms and servers.
If you are using CB's "objectid" convention, your values should already meet these requirements and will not be changed by sanitizing. 
However, if your objectid contain odd characters (and are thus sanitized), links in the rest of the collection site may not point to the correct url.
If for some reason you can not clean up your objectid field, you can  apply slugify filter to objectid in other page templates when calculating links to fix the issue.

If customizing new Item types, it maybe helpful to tweak the "Default Settings" values in CollectionBuilderPageGenerator (as an alternative to passing configuration values).

*Note:* CollectionBuilder originally used a modified version of [Adolfo Villafiorita jekyll-datapage_gen](https://github.com/avillafiorita/jekyll-datapage_gen), however, the plugin has been completely rewritten following the basic [Jekyll Generator Plugins](https://jekyllrb.com/docs/plugins/generators/).
This allows CB Page Gen to more closely follow CB conventions, configuration options, and needs.
Much of this is CB specific, such as providing metadata-centric defaults and fairly detailed error messages.
However, the plugin configuration is still fully backwards compatible with older jekyll-datapage_gen configuration options (as used in CB projects). 
If you used the old page gen plugin, your existing configuration should work with the new one.
As of 2020, jekyll-datapage_gen added additional options that are *not* supported in CB Page Gen (index_files, name_expr, title, title_expr)--if you would like to use those options, you should still be able to swap in the newest version of jekyll-datapage_gen and delete cb_page_gen.

## Array Count Uniq

"Array Count Uniq" (`array_count_uniq.rb`) provides a convenient Liquid filter to calculate the count of unique values in an array.
The filter takes a Liquid array as input and returns an array of the unique values and their counts. 
This allows you to quickly extract unique terms from large metadata files, which would take too long using Liquid alone.
This is some what idiosyncratic to the needs of CollectionBuilder projects, used to efficiently generate Cloud pages and data derivatives.

For example, used in a project like `{% assign unique_terms = myarray | array_count_uniq %}`, 
will return an array like `[ ["term one",2], ["term two",6], ["term three",1]]`,
which can then be used in further Liquid.
