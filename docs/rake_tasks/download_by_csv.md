# download_by_csv

`rake download_by_csv` downloads a list of files (URLs) from a CSV.

Optionally, the task can rename the files it downloads so you can normalize filenames at the same time.
This is sometimes required when download filenames would be the same, such as downloading from a IIIF server where all items are "default.jpg".

If errors are encountered, the task outputs "download_errors.csv" providing information about the items that were unsuccessful.

This task is helpful to set up a self-contained "objects" folder for a project by downloading external resources from a repository or S3 bucket.

Using defaults:

- Create a CSV named "download.csv" with columns "url" (the full link to the objects you want to download) and "filename_new" (optional, the name you want to save/rename the downloaded objects as). Make sure it is UTF-8 (not from Excel).
- Put "download.csv" into the root of this repository (i.e. same place as the Rakefile).
- Open terminal and type `rake download_by_csv`
- Items included in the "download.csv" will be downloaded, renamed, and output in new folder "download/".

The options can be changed by passing arguments with the rake command.

| option | description | default value |
| --- | --- | --- |
| csv_file | the filename of the CSV file used to rename | "download.csv" |
| download_link | the column name that is the full link to the objects you want to download | "url" |
| download_rename | the column name of the new filename for the downloads (optional, if you don't provide one, it will use what ever the url uses) | "filename_new" |
| output_dir | the name of the new folder to download the files | "download/" |
| delay | seconds to wait between requests, to keep the load on the server you are downloading from reasonable and avoid rate limits | 1 |

The order follows [:csv_file,:download_link,:download_rename,:output_dir,:delay].
For example,

`rake download_by_csv["other_down.csv","item_link","new_name","download_folder",2]`

To download as fast as possible, set the delay to 0.
Please be considerate with collections held by other institutions!
A short delay is often the difference between a download that finishes and one that gets blocked part way through.

## How the download works

The task uses only the Ruby standard library, so there is nothing to install beyond the normal project setup (`bundle install`).
*Note:* earlier versions of this task required Wget, which is no longer needed.

**Redirects.**
Permalinks are followed automatically, up to ten hops per item, including relative locations and hops that change host or scheme.
This covers the usual DOI, Handle, ARK, CONTENTdm, and repository "download" links.
Any session cookie set along the way is sent to the following hops, which many repository platforms require.
The final URL of the chain is used to work out the filename.

**Filenames.**
If the "filename_new" column has a value, it is used.
Otherwise the name comes from the server's content disposition header, then from the last part of the final URL, and finally from the row number plus an extension guessed from the file type.
Names are always cleaned up so a download can only ever be written inside your output folder.

**Resuming.**
Files that already exist in the output folder are skipped, so you can run the task again after fixing errors without downloading everything a second time.
Each file is written to a temporary ".part" file and only given its real name once the download finishes, so an interrupted run never leaves a broken or empty object behind.

**Errors.**
Timeouts, dropped connections, and temporary server errors (such as 429 and 503) are tried up to three times, waiting longer between each attempt and honoring the server's own "retry after" header.
A row that still fails does not stop the run.
When the task finishes, any failures are listed in "download_errors.csv" inside the output folder, with the URL, the intended filename, and the reason.
That file can be used as the input CSV to retry just those items:

`rake download_by_csv["download/download_errors.csv"]`

## Troubleshooting

- **"the server returned a web page"** means the URL gave back HTML rather than the object. Usually the link points at an item landing page instead of the file itself, or the object requires a login.
- **403 or 404 errors** on links that work in your browser usually mean the repository requires a session or referring page. Try the direct file URL rather than the permalink.
- **certificate errors** mean the server's HTTPS setup is broken or out of date. Check whether the collection is also available over a different host.
- **downloads that stall** are usually rate limiting. Raise the delay, for example `rake download_by_csv["download.csv","url","filename_new","download/",5]`.
