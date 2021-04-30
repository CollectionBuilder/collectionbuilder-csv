# Table visualization

Powered by DataTables, https://datatables.net/ 

Using [DataTables Download](https://datatables.net/download/index), we package a variety of plugins/Extensions with the asset (Bootstrap 4 styling, Buttons + HTML5 export + JSZip, minified and concatenated).

`_data/config-table.csv` provides the basic options. 
The fields listed in the config will become the columns of the table, plus a link to the item which is automatically added.
The link will be rendered as a hyperlink on the web table around the content of the first column, which will typically be "Title".
The table will be sorted by the second column (typically "Date").

The config-table options drive the creation of:

- table viz page (`/data.html`)
- `/assets/js/metadata.min.json` is the table data in an optimized format specifically intended for the consumption by the table viz page in this project. Each item is a list of values without keys and links are relative.

Since the fields listed will become columns of the web table, it is best to not select too many. 
The table will render well with about 3 to 5 fields.
It will become too crowded with narrow columns if more are added.
Typical columns are: title, date, description, subjects.
With large collections, avoid fields with lots of text, as this will make the json data slow to load.

DataTables is set up in `/_includes/js/table-js.html`. 
It loads `metadata.min.json` using ajax which optimizes initial page load time. 
Options are set to optimize for very large data sets (deferRender, paging). 
We have had success with over 90,000 items.
Usability is mainly limited by load time of the metadata json (which may get to be > 3MB).

DataTables Buttons extension with HTML5 Export and JSZip is used to add download/export buttons to the web table. 
Clicking the CSV or Excel button will export the current subset of metadata displayed on the web table. 
The export will automatically include a Link column with full link to the 

Note: since this table is a small subset of metadata fields, the `/assets/data/metadata.csv` and `/assets/data/metadata.json` data download is driven by the `site.data.theme.metadata-export-fields` rather than table config. 
This means the CSV/JSON download can be more complete, containing more fields than are displayed anywhere on the site.
