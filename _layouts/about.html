---
# default "About" page layout
# provides a full width featured image at top
# with an auto generated TOC nav on the left and a narrow text block 
layout: default
---

{% if page.about-featured-image or page.heading or page.sub-heading %}

{% assign jumboId = page.about-featured-image %}
{% if jumboId contains '/' %}
{% assign jumboSrc = jumboId | relative_url %}
{% else %}
{% assign jumboItem = site.data[site.metadata] | where: "objectid", jumboId | first %}
{% capture jumboSrc %}{{ jumboItem.object_location | default: jumboItem.image_small | relative_url }}{% endcapture %}
{%- endif -%}

<style>
    #about-feature {
        padding: 4rem 0;
        margin-bottom: 1rem;
        {% if page.about-featured-image %}
        background-color: #e9ecef;
        background-image: url({{ jumboSrc }});
        background-size: cover;
        background-repeat: no-repeat;
        background-position: {{ page.position | default: 'center' }};{% endif %}
    }
    {% if page.padding %}
    .about-title-box {
        padding-top: {{ page.padding }};
        padding-bottom: 1em;
    }
    {%- endif -%}
    .about-title {
        padding-left: 15% !important;
    }
    @media screen and (max-width: 576px) {
        .about-title-box {
            padding-top: min({{ page.padding }}, 45vh);
        }
        .about-title {
            padding-left: 1rem !important;
        }
    }
</style>
<div id="about-feature">
    <div class="about-title-box">
        {% if page.heading or page.sub-heading %}
        <div class="p-2 text-start text-white bg-dark bg-opacity-75 about-title">
            {% if page.heading %}<h2 class="display-1">{{ page.heading }}</h2>{% endif %}
            {% if page.sub-heading  %}<h3 class="about-tagline h5">{{ page.sub-heading }}</h3>{% endif %}
        </div>
        {% endif %}
    </div>
</div>
{% endif %}

<div id="about-wrapper">
    <div id="about-toc-wrapper">
        {% unless page.toc == false %}
        <div id="about-toc">
            <div id="about-toc-title">
                <button class="btn btn-light" data-bs-toggle="collapse" data-bs-target="#about-toc-list" aria-expanded="false" aria-controls="about-toc-list">
                    Contents
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-down" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"/>
                    </svg>
                </button>
            </div>
            <div id="about-toc-list" class="collapse" > 
            {% include cb/jekyll-toc.html html=content sanitize=true h_min=1 h_max=3 skip_no_ids=true class="jekyll-toc-list" credits=page.credits %}
            </div>
        </div>
        {% endunless %}
    </div>
    <div id="about-contents-wrapper">
        {{ content }}
    </div>
    {% if page.credits == true %}
    <div id="credits-contents-wrapper">
        {% include cb/credits.html %}
    </div>
    {% endif %}
</div>