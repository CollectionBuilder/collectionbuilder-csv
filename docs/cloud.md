# Create Cloud Visualizations

## Built-in clouds

For simplicity, the default CB theme has a pre-configured cloud visualization page pre-configured named "Locations".
These can be configured using variables in the "\_data/theme.yml" to generate clouds from any field(s) in your metadata (not necessarily just a "location" field).
The theme options look like:

```
# Locations page
locations-fields: location # set of fields separated by ; to be featured in the cloud
locations-min: 1 # min size for subject cloud, too many terms = slow load time!
locations-stopwords: # set of subjects separated by ; that will be removed from display, e.g. boxers;boxing
```

The file "pages/locations.md" pulls in these values to create the default cloud page.
The settings also create matching data outputs in the "/assets/data/" folder.

If `locations-fields` is blank or commented out, the template will not build out the related cloud page or data, which saves build time.
If you are developing a particularly large collection, you can comment out these options to make rebuild much quicker.

Keep in mind this page stub (`/locations.html`) will also have to be present in "config-nav.csv" to show up in your navigation, and to have the data files to show up in data download options.

## Cloud Layout and Front matter

Custom cloud pages can be easily created using the cloud layout and page front matter.
Create a new page stub with standard front matter, and add these cloud values:

- `cloud-fields:`, with a value of a set of fields separated by `;` to be featured in the cloud.
- `cloud-min:` (optional), with a integer value such as `2`.
- `cloud-stopwords:` (optional), with a set of terms separated by `;` that will be removed from display.

For example, to create an "Authors" cloud page, create a file named "authors.md" in the "pages" folder.
Edit the "authors.md" with this front matter and content:

```
---
title: Authors
layout: cloud
permalink: /authors.html
cloud-fields: creator
cloud-min:
cloud-stopwords:
---

## Browse Authors

Example custom cloud page.
```

## Cloud include

Clouds can also be directly added to any page using the "\_include/js/cloud-js.html" include in the page stub content.
This makes it possible to embed a cloud anywhere in other interpretive content pages.

First, add a div with `id="cloud"` where you want the cloud to display.
Then below the div add the cloud-js include and provide the variable `fields`, and optionally variables `min` and `stopwords`.

For example:

```
<div id="cloud" class="text-center my-4 bg-light border rounded p-2"></div>
{% include js/cloud-js.html fields="creator;publisher" min=2 stopwords="example;another" %}
```
