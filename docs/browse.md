# Browse Page

## browse-facets

Search engine plain JS, no library**

- **Why the matching changes:** users of digital collections expect catalog / search-engine behavior: several loose words, every word must match, forgiving of partial words and plurals, best matches first. Pure substring matching fails multi-word queries and produces false hits.
- **Why not lunr or itemsjs:**
  - no partial-word matching without wildcards
  - no phrase search
  - English-only stemmer and stop words
  - errors on query syntax characters
  - an extra 30–61 KB
- **Why plain JS is enough:** at CollectionBuilder scale (hundreds to low thousands of items, short metadata), a simple word-prefix matcher with field weights gives most of the benefit. It works in any language and stays readable and editable. See section 3 for the algorithm.
- **Keep it swappable:** the matcher sits behind one function, `searchItems(query)`, so a site could replace it with lunr later without touching facets, sorting or rendering.

### front matter config

configuration keys are added to the layout front matter

- `browse-facet-size: 8`: values shown before a "Show all N" button.
- `browse-facet-sort: count`: or `alpha`.
- `browse-facet-logic: or`: `and` for strict drill-down.

advanced-search: true # true / false, adds the Advanced search button and modal
default-sort-field: # blank = random; "title"; or a field with a sort_name in config-browse-facets.csv
default-sort-order: asc # asc / desc
browse-per-page: 48 # number of items shown before the "Show more items" button
browse-facet-size: 8 # number of values shown in each facet before the "Show all" button
browse-facet-sort: count # count / alpha, order of values in each facet
browse-facet-logic: or # or / and, how multiple selected values in the same facet are combined

### config-browse-facets 

| column | use |
|---|---|
| `field` | metadata column name. Only listed fields are included in the page data, plus the built-ins below |
| `display_name` | label shown on cards (blank = value shown without a label) |
| `btn` | `true` = on cards, values are split on `;` and shown as filter links (D8) |
| `hidden` | `true` = not shown on cards; the field can still be searched, faceted, or sorted |
| `search` | `true` = included in keyword search. optionally can be a number which allows boosting specific fields in general search. |
| `date_field` | `true` = treat as a date field for search and facets |
| `multivalued` | `true` = treat as multivalued split on `;` for search and facets |
| `sort_name` | if set, the field is offered in the sort menu under this label, ascending and descending (D6) |
| `facet_name` | if set, the field is a facet in the sidebar with this heading. |

- **Built-in fields** (always in the data, not needed in the CSV): `objectid`, `title`, `parentid`, `image_thumb`, `image_alt_text`, `display_template`, `format`.
- `title` is always searched with extra weight. per-field search weight can optionally be set by the search config option to boost other fields.
- fields to treat as dates are configured in config-browse-facets.csv. This drives the date-range inputs in advanced search and the date sort labels (D6).
- if a facet_name is configured, a date range facet is added to the facets.
- data loads from generated JS file `assets/js/browse-store.js`