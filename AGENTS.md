# CollectionBuilder-CSV — AI Agent Instructions

CollectionBuilder-CSV is a Jekyll-based framework for building digital collection and exhibit websites from a spreadsheet of metadata plus a folder of objects. It follows a **minimal computing** philosophy: static output, few dependencies, and configuration over code. The framework is **data-driven** — nearly all UI configuration comes from CSV files and YAML, not from editing HTML/Liquid templates. Understanding and following this architecture is critical.

> **Companion files in this repo:** `CLAUDE.md` imports this file so Claude Code and Claude Cowork get the same rules. `HUMANS.md` is the human-facing guide to working with AI on this project. Keep all architecture rules here in `AGENTS.md` — the other two point back to it.

## Customization Priority Order

**Always check if a change can be made at a higher level before editing lower-level files:**

1. **`_config.yml`** — Site identity, org branding, and the `metadata:` pointer (filename of the active metadata CSV in `_data/`, no `.csv` extension)
2. **`_data/theme.yml`** — Visual behavior: navbar colors, map/timeline settings, typography, featured image, browse/search feature toggles
3. **`_data/config-*.csv`** — Controls what fields appear on item pages, browse cards, search index, map popups, nav links, and table columns
4. **`pages/about.md` and content pages** — Authored content using `_includes/feature/` includes
5. **`_sass/_custom.scss`** — CSS-level overrides only when the above layers cannot accomplish the goal

## Critical Rules — Never Violate These

**Navigation**
- Never edit `_includes/collection-nav.html` to add or remove links
- Add rows to `_data/config-nav.csv` instead
- The `dropdown_parent` column enables dropdown menus

**Item Page Metadata Fields**
- Never edit item layout HTML to show/hide fields
- Edit `_data/config-metadata.csv`: add/remove rows and set `display_name`, `browse_link`, and `external_link`

**Browse Page Cards**
- Fields on browse cards, facets, and sort options are configured in `_data/config-browse.csv`
- Do not touch `_layouts/browse.html` for field-level changes

**Custom CSS**
- Write all custom styles in `_sass/_custom.scss`
- Never modify `_base.scss`, `_pages.scss`, or `_theme-colors.scss`
- `_custom.scss` is `@use`d last in `assets/css/cb.scss` and wins specificity

**Metadata Pointer**
- `_config.yml` has `metadata: <filename>` with **no `.csv` extension**
- The collection is accessed as `site.data[site.metadata]` — bracket notation is required, not dot notation

**Item Pages Are Auto-Generated**
- `_plugins/cb_page_gen.rb` generates item pages from the metadata CSV at build time
- Never create `.html` files in `items/`
- The `display_template` column in the metadata CSV selects the layout
- Valid values: `image`, `video`, `pdf`, `audio`, `record`, `compound_object`, `panorama`, `multiple` (no `item/` prefix)

**Bootstrap 5**
- This project uses Bootstrap 5
- Use `ms-`/`me-` (not `ml-`/`mr-`), `float-start`/`float-end`, `data-bs-toggle=` (not `data-toggle=`)
- Use `d-flex`/`gap-*` utilities

**Production-Only Features**
- Analytics, Schema.org/OG meta tags, and `noindex` settings are wrapped in `{% if jekyll.environment == "production" %}`
- They will not appear during `bundle exec jekyll serve`

## Ask Before Doing These

Some changes are legitimate but destructive or hard to undo. Explain your plan and get the user's confirmation before:

- **Restructuring or reordering columns** in `_data/<metadata>.csv` (other config CSVs reference these column names)
- **Bulk-editing many item rows** at once, rather than a targeted change
- **Changing `display_template`** across the whole collection
- **Rewriting a config CSV's structure** (vs. adding or removing a single row)
- **Deleting rows** from any `config-*.csv` — confirm the field isn't referenced elsewhere first

## Data Files Quick Reference

| File | What it controls |
|------|-----------------|
| `_config.yml` | Site identity, `metadata:` CSV pointer, org info |
| `_data/theme.yml` | Visual settings, page features, map/timeline/browse config |
| `_data/config-metadata.csv` | Fields shown on item pages |
| `_data/config-browse.csv` | Browse card fields, facets, sort options |
| `_data/config-search.csv` | Lunr.js indexed fields and search result display |
| `_data/config-nav.csv` | Navbar and footer navigation links |
| `_data/config-map.csv` | Map popup field display |
| `_data/config-table.csv` | Data page table columns |
| `_data/config-theme-colors.csv` | Bootstrap color class overrides (primary, secondary, etc.) |
| `_data/<metadata>.csv` | The collection items; drives all visualizations |

## Feature Includes

For rich content in `about.md` and other Markdown pages, always use `_includes/feature/` includes — do not write raw HTML. Every feature is a drop-in Liquid include:

```liquid
{% include feature/image.html objectid="demo_001" width="75" %}
{% include feature/card.html header="Card Title" text="Body text" objectid="demo_004" %}
{% include feature/gallery.html filter-field="subject" filter-value="mining" item-size="small" %}
{% include feature/alert.html text="Important note!" color="warning" %}
{% include feature/button.html text="Browse Items" link="/browse.html" color="primary" %}
{% include feature/jumbotron.html objectid="demo_001" heading="My Heading" text=false %}
{% include feature/video.html objectid="demo_003" width="75" %}
{% include feature/audio.html objectid="demo_007" %}
{% include feature/blockquote.html text="Quote text" speaker="Author Name" %}
{% include feature/accordion.html title1="Section 1" text1=capturedVar open=true %}
```

For multi-line text params, use Liquid `capture` before the include:
```liquid
{% capture section1 %}
This is **markdown** content spanning multiple lines.
{% endcapture %}
{% include feature/accordion.html title1="My Section" text1=section1 %}
```

Pass `false` (no quotes) to suppress a default: `{% include feature/image.html objectid="demo_001" caption=false %}`

## Common Mistakes to Avoid

1. **Editing `_includes/` or `_layouts/` when CSV config would work** — Always check if a data file can accomplish the task
2. **Adding `.csv` extension to metadata pointer** — `metadata:` value should never include the extension
3. **Using `site.data.metadata`** — Must use `site.data[site.metadata]` with bracket notation
4. **Creating item pages manually** — They're auto-generated from the metadata CSV
5. **Using Bootstrap 4 syntax** — This is Bootstrap 5: use `ms-`/`me-`, not `ml-`/`mr-`
6. **Modifying base SCSS files** — All custom CSS belongs in `_sass/_custom.scss` only
7. **Prefixing display_template values** — Use `image`, not `item/image`

## SCSS / Theming

Typography and color values from `_data/theme.yml` flow into SCSS at compile time via `assets/css/cb.scss`. To change fonts, colors, or Bootstrap theme colors:

1. For broad visual changes: edit `_data/theme.yml` (keys: `base-font-size`, `text-color`, `link-color`, `base-font-family`, `font-cdn`, `navbar-background`, `navbar-color`)
2. For Bootstrap semantic colors: edit `_data/config-theme-colors.csv`
3. For everything else: write SCSS in `_sass/_custom.scss`

## Reference Documentation

When you need detailed information, consult these files in the repository:

- **`docs/markup.md`** — Full feature include parameter reference
- **`docs/metadata.md`** — Metadata CSV column definitions
- **`docs/compound_objects.md`** — Compound object structure and `parentid` usage
- **`docs/color_theme.md`** — Theme colors and Bootstrap theming
- **`docs/advanced_theme.md`** — Fonts, Bootswatch, advanced SCSS
- **`docs/maps.md`** — Map configuration options
- **`docs/gallery.md`** — Gallery include options
- **`docs/item_pages.md`** — Item page generation and templates
- **`_includes/cb/feature_options.md`** — Inline feature include documentation
- **`_includes/cb/about_the_about.md`** — About page structure guide

## Build Commands

```bash
bundle exec jekyll serve    # Local development server (localhost:4000)
bundle exec jekyll build    # Production build
JEKYLL_ENV=production bundle exec jekyll build  # Build with analytics/meta tags
bundle exec rake            # List available rake tasks
```

## Working Instructions

When given a task:

1. **Read the request carefully** and identify which layer of the customization hierarchy it affects
2. **Check documentation** in `docs/` if you need detailed information about a feature
3. **Make changes at the appropriate level** — prefer CSV/YAML over template edits
4. **Explain your approach** before making changes if the task is non-trivial
5. **Test that changes follow the data-driven architecture** — if you're editing `_includes/` or `_layouts/`, verify a config file cannot accomplish the same goal

For questions about CollectionBuilder framework itself, the user can consult the [official documentation](https://collectionbuilder.github.io/cb-docs/) or [discussion forum](https://github.com/CollectionBuilder/collectionbuilder.github.io/discussions).