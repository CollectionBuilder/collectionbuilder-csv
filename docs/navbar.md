# Nav configuration

The navigation bar in the CollectionBuilder template uses the [Bootstrap navbar component](https://getbootstrap.com/docs/4.4/components/navbar/) to add links to the main pages and a search box. 
The Bootstrap navbar automatically collapses into a menu button on smaller screens (break point `-lg`, which is approximately tablet size). 

The navbar is configured using "_data/config-nav.csv". 
It is added to the default layout (so that every page has it) using "_includes/collection-nav.html". 
The same nav items will also be automatically added to the footer ("_includes/footer.html").
The navbar colors can be configured in theme.yml (see "advanced-theme.md").

config-nav allows you to easily control which pages will show up in your navbar and how they are labelled, as well as create dropdown menus.
Removing an item does not delete the page, but will make the page invisible to users.
Each item in the nav is one row of config-nav, including the columns `display_name`, `stub`, and `dropdown_parent`: 

- `display_name` will be the word(s) used on the navbar. Generally you will want these to be single words that are easy for users to understand--typically: Home, Browse, Subjects, Locations, Map, Timeline, Data, About. Modifying this value allows you to quickly change the display name without needing to update the file names or titles. e.g. for some collections a label such as "Creators" might replace "Subjects", while still pointing to the /subjects.html page.
- `stub` is the relative url of the page in this project. To properly link to a page, the `stub` value will match the `permalink` value of a specific page file. e.g. "browse.md" has `permalink: /browse.html`, thus in config-nav has a stub value of `/browse.html`. These will be converted into relative links in the navbar. The `stub` value will be empty for items that are parents for a dropdown menu (see below).
- `dropdown_parent` is only used when adding dropdowns to your navbar, and should be empty for any normal nav item. For items that should appear inside a dropdown, the value will match the `display_name` of the parent item (see below).

## Dropdown menus

A [Bootstrap dropdown menu](https://getbootstrap.com/docs/4.4/components/dropdowns/) can be added to a nav item following this convention in config-nav:

- if the item has a `stub`, but no value in `dropdown_parent`, it becomes a normal nav item
- if the item has NO `stub`, it will become a dropdown menu
- if the item has a value in `dropdown_parent`, it will only show up under the parent dropdown

For example, a dropdown with two pages under the label About would look like:

```
display_name,stub,dropdown_parent
About,,
About the Collection,/about.html,About
CollectionBuilder,/tech.html,About
```

"About" (with no value in stub or dropdown_parent) would appear in the navbar as a dropdown button. 
When clicked, the dropdown would appear with "About the Collection" and "CollectionBuilder" listed.

Note: dropdowns do NOT appear in the footer nav. The parent will appear, with a link to the top child. 
