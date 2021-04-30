# Analytics 

Analytics is only included when building with "JEKYLL_ENV=production".
By default, Jekyll is in the development ENV, and analytics will not be added.
Paste this command into Git Bash or Terminal: 

`JEKYLL_ENV=production jekyll build`

Or use our short cut Rake task: 

`rake deploy`

## Set up

We use google analytics, using the newest implementation gtag.
The same code snippet can be used on any web page. 
Looks like:

```
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-76328753-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  /* load umbrella property with enhanced link attribution and cross domain tracking */
  gtag('config', '{{ site.google-analytics-id }}', {
    'link_attribution': true
  });
</script>
```

## Enhanced link attribution 

is enabled. 
Uses ID of link or nearby parent to specify which link (of all the same href on a page) was actually clicked.

https://developers.google.com/analytics/devguides/collection/gtagjs/enhanced-link-attribution

## Cross domain tracking

Fairly easy to set up using gtag. 
We just have to provide a list of all domains we want to track across, can use same snippet on all pages and domains.  

https://developers.google.com/analytics/devguides/collection/gtagjs/cross-domain
