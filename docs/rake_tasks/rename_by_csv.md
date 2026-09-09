# rename_by_csv

This task allows you to rename a batch of files using a spreadsheet.

This is helpful for normalizing filenames for use in a project and on the web, allowing you to use spreadsheet tools to batch generate the new names, often directly in your CB metadata CSV.
For example, you might keep the old filename in "original_filename" for archival purposes, then create a new "filename" field based on the "objectid" of the item and the standardize file extensions.

Be sure to include file extensions in both your old and new filename columns!
However, keep in mind it does NOT convert file types, just renames, so changing the file extension should be done with care.
Changing the file extension can be useful to normalize situations such as `.jpeg` to `.jpg` or inconsistent case (`.PDF` to `.pdf`).

Using defaults: 

- Create a CSV named "rename.csv" with the columns "filename_old" (the exact matching current filename, not including directory) and "filename_new" (the new name you want, not including directory). Make sure it is UTF-8 (not from Excel).
- Put your files into the "objects" folder.
- Put your "rename.csv" into the root of this repository (i.e. same place as the Rakefile).
- Open terminal and type `rake rename_by_csv`
- Items included in the "rename.csv" will be copied, renamed, and output in the new folder "renamed/". (nothing will be deleted!)

The options can be changed by passing arguments with the rake command.

| option | description | default value |
| --- | --- | --- |
| csv_file | the filename of the CSV file used to rename | "rename.csv" |
| filename_current | the column name of the old filename | "filename_old" |
| filename_new | the column name of the new filename | "filename_new" |
| input_dir | the name of the folder containing the files to be renamed | "objects/" |
| output_dir | the name of the new folder to put the renamed files | "renamed/" |


The order follows [:csv_file,:filename_current,:filename_new,:input_dir,:output_dir].
For example, 

`rake rename_by_csv["other_rename.csv","old_name","new_name","raw_folder","new_folder"]`
