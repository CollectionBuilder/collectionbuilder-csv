# download_by_csv

`rake download_by_csv` allows you to download a list of files from a CSV using Wget.

Please ensure you have Wget installed and available on your terminal!
Check by typing `wget --version` in your terminal. 
If you need to install on Windows, see [Add more to Git Bash](https://evanwill.github.io/_drafts/notes/gitbash-windows.html).

Requirements:

- wget

Using defaults:

- Create a CSV named "download.csv" with columns "url" (the full link to the objects you want to download) and "filename_new" (optional, the name you want to save/rename the downloaded objects as). Make sure it is UTF-8 (not from Excel). 
- Put "download.csv" into the root of this repository (i.e. same place as the Rakefile).
- Open terminal and type `rake download_by_csv`
- Items included in the "download.csv" will be downloaded using wget, renamed, and output in new folder "download/".

The options can be changed by passing arguments with the rake command.

| option | description | default value |
| --- | --- | --- |
| csv_file | the filename of the CSV file used to rename | "download.csv" |
| download_link | the column name that is the full link to the objects you want to download | "url" |
| download_rename | the column name of the new filename for the downloads (optional, if you don't provide one, it will use what ever the url uses) | "filename_new" |
| output_dir | the name of the new folder to download the files | "download/" |


The order follows [:csv_file,:download_link,:download_rename,:output_dir].
For example, 

`rake download_by_csv["other_down.csv","item_link","new_name","download_folder"]`
