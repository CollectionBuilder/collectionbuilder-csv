# rename_lowercase

This task takes a folder of files and copies them to a new folder with all filenames downcased. 

Using default:

- Put your files into the "objects/" folder.
- Open terminal and type `rake rename_lowercase`
- All files in "objects/" will be copied, filenames converted to lowercase, and output to a new folder "renamed/". (nothing will be deleted!)


| option | description | default value |
| --- | --- | --- |
| input_dir | the name of the folder containing the files to be renamed | "objects/" |
| output_dir | the name of the new folder to put the renamed files | "renamed/" |


The order follows [:input_dir,:output_dir].
For example, 

`rake rename_lowercase["raw_folder","new_folder"]`
