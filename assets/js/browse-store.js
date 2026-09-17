---
# create js data store for the browse-facets layout
# fields are set in _data/config-browse-facets.csv
# child objects are included if theme.yml browse-child-objects is true
---
{%- if site.data.theme.browse-child-objects == true -%}
{%- assign items = site.data[site.metadata] | where_exp: 'item','item.objectid' -%}
{%- else -%}
{%- assign items = site.data[site.metadata] | where_exp: 'item','item.objectid and item.parentid == nil' -%}
{%- endif -%}
{%- assign fields = site.data.config-browse-facets -%}
{%- assign builtins = "objectid,title,parentid,image_thumb,image_alt_text,display_template,format" | split: "," -%}
var browseStore = [
{%- for item in items %}
{
{%- for f in fields -%}{%- unless builtins contains f.field -%}{%- if item[f.field] -%}{{ f.field | jsonify }}:{{ item[f.field] | normalize_whitespace | strip | jsonify }},{%- endif -%}{%- endunless -%}{%- endfor -%}
{%- if item.parentid -%}"parentid":{{ item.parentid | jsonify }},{%- endif -%}
{%- if item.image_thumb -%}"image_thumb":{{ item.image_thumb | relative_url | jsonify }},{%- endif -%}
{%- if item.image_alt_text -%}"image_alt_text":{{ item.image_alt_text | strip | jsonify }},{%- endif -%}
{%- if item.display_template -%}"display_template":{{ item.display_template | strip | jsonify }},{%- endif -%}
{%- if item.format -%}"format":{{ item.format | strip | jsonify }},{%- endif -%}
{%- capture item_url -%}/items/{% if item.parentid %}{{ item.parentid }}.html#{{ item.objectid }}{% else %}{{ item.objectid }}.html{% endif %}{%- endcapture -%}
"url":{{ item_url | relative_url | jsonify }},
"title":{{ item.title | default: item.objectid | strip | jsonify }},
"objectid":{{ item.objectid | jsonify }}
}{%- unless forloop.last -%},{%- endunless -%}
{%- endfor %}
];
