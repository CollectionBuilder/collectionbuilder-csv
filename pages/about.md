---
title: About
layout: about
permalink: /about.html
# include CollectionBuilder info at bottom
credits: true
# Edit the markdown on in this file to describe your collection
# Look in _includes/feature for options to easily add features to the page
---

{% include feature/jumbotron.html objectid="https://cdil.lib.uidaho.edu/images/palouse_sm.jpg" %} 

{% include feature/nav-menu.html sections="About CollectionBuilder SA;About the About Page" %}

## About CollectionBuilder CSV

This demo collection features items from the University of Idaho Library's [Digital Collections](https://www.lib.uidaho.edu/digital/), and is build using [CollectionBuilder-CSV](https://github.com/CollectionBuilder/collectionbuilder-csv).

CollectionBuilder-CSV is a "Stand Alone" template for creating digital collection and exhibit websites using Jekyll, given:

- a CSV of collection metadata
- a folder of images, PDFs, audio, or video files

Driven by your collection metadata, the template generates engaging visualizations to browse and explore your objects.
The resulting static site can be hosted on any basic web server.

[CollectionBuilder](https://github.com/CollectionBuilder/) is an set of open source tools for creating digital collection and exhibit websites that are driven by metadata and powered by modern static web technology.
See [CB Docs](https://collectionbuilder.github.io/cb-docs/) for detailed information.

{% include feature/image.html objectid="demo_001" width="75" %} 

<!-- IMPORTANT!!! DELETE this comment and the include below when you are finished editing this page for your collection. The include below introduces about page features. They will show up on your collection's about page until you delete it.  -->
{% include cb/about_the_about.md %} 
