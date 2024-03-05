# Analytics 

CollectionBuilder templates have a builtin method to add analytics tracking snippets to your site.

Any analytics platform can be added by pasting the tracking snippet they provide into "_includes/head/analytics.html".
During "production" build *only*, the include is added to the head of every page.
By default, Jekyll is in the "development" environment, so analytics will not be added while you are testing your site locally.

## Production environment

Analytics is only included when building with `JEKYLL_ENV=production`.
By default, Jekyll is in the development environment, and analytics will not be added.
To add analytics during build, use this command into Git Bash or Terminal: 

`JEKYLL_ENV=production bundle exec jekyll build`

Or use our short cut Rake task: 

`rake deploy`
