# Create List Visualizations

## Built-in lists

For simplicity, the default CB theme has a pre-configured list visualization page pre-configured named "Subjects". 
These can be configured using variables in the "_data/theme.yml" to generate the list from any field(s) in your metadata (not necessarily just a "subject" field). 
The theme options look like:

```
# Subject page
subjects-fields: subject;creator # set of fields separated by ; to be featured in the list
subjects-min: 1 # min size for subject list, too many terms = slow load time!
subjects-stopwords: # set of subjects separated by ; that will be removed from display, e.g. boxers;boxing
```

The file "pages/subjects.md" pulls in these values to create the default list page.
The settings also create matching data outputs in the "/assets/data/" folder.

If `subjects-fields` is blank or commented out, the template will not build out the related list page or data, which saves build time. 
If you are developing a particularly large collection, you can comment out these options to make rebuild much quicker. 

Keep in mind this page stub (`/subjects.html`) will also have to be present in "config-nav.csv" to show up in your navigation, and to have the data files to show up in data download options. 

## List Layout and Front matter

Custom list pages can be easily created using the list layout and page front matter.
Create a new page stub with standard front matter, and add these values: 

- `fields:`, with a value of a set of fields separated by `;` to be featured in the list.
- `min:` (optional), with a integer value such as `2`.
- `stopwords:` (optional), with a set of terms separated by `;` that will be removed from display.

For example, to create an "Authors" list page, create a file named "authors.md" in the "pages" folder. 
Edit the "authors.md" with this front matter and content:

```
---
title: Authors
layout: list
permalink: /authors.html
fields: creator
min: 
stopwords:
---

## Browse Authors

Example custom list page.
```


