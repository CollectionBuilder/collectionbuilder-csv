# Analytics 

CollectionBuilder templates have a builtin method to add analytics tracking snippets to your site.

Any analytics platform can be added by pasting the tracking snippet they provide into "_includes/head/analytics.html".
During "production" build *only*, the include is added to every page.
By default, Jekyll is in the "development" environment, so analytics will not be added while you are testing your site locally.

Since many people will opt to use Google Analytics, we provide a pre-configured tracking code snippet that can be added simply by pasting your Google Analytics ID as the `google-analytics-id` value in "_config.yml".
The template uses the "gtag.js" implementation, with the [Anonymize IP](https://developers.google.com/analytics/devguides/collection/gtagjs/ip-anonymization) enabled to provide basic privacy enhancement to your users.

However, there are many alternatives emerging, so you may want to explore the options in your context to avoid concerns over data privacy.

We have been very satisfied using self-hosted [Matomo](https://matomo.org/).

## Production environment

Analytics is only included when building with `JEKYLL_ENV=production`.
By default, Jekyll is in the development environment, and analytics will not be added.
To add analytics during build, use this command into Git Bash or Terminal: 

`JEKYLL_ENV=production bundle exec jekyll build`

Or use our short cut Rake task: 

`rake deploy`

## Advanced Google options

You may want to add:

- [enhanced link attribution](https://developers.google.com/analytics/devguides/collection/gtagjs/enhanced-link-attribution)
- [cross domain tracking](https://developers.google.com/analytics/devguides/collection/gtagjs/cross-domain)
