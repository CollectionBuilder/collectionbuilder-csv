# Code Design Notes

General notes about how the template is set up, design decisions, and features available to customize the code. 

## Template Page Design

Generally CB template pages are made of three parts:

- a "stub" found in "pages" folder, generally in markdown. The stub can contain markdown content and feature includes, but should not generally contain complicated JS.
- a "layout" found in "_layouts" folder, in html. This is the template html that the content will be injected into. Most layouts will have an additional layout of "page" or "default".
- component includes found in "_includes" folder, generally in html. Includes contain modular components of html, JS, and Liquid that add content or code to the page.

To ensure JS is loaded in correct order, JS includes are added via the "_includes/foot.html".
See "docs/foot.md" for details.

## Links and Btn

We use Bootstrap button classes to style many of our links. 
If they are actual links, i.e. go to a different page or to an anchor on the page, they should NOT have the attribute `role="button"` since this can trigger odd rendering and unnecessary screen reader interactions. 
For example, `<a class="btn btn-primary" href="https://example.com">Link</a>`.

If `<a>` tags are used to trigger interactivity on the page, for example opening a modal, then they SHOULD have `role="button"` for accessibility purposes. 
For example, `<a class="btn btn-primary" href="#" role="button" data-toggle="modal" data-target="#exampleModal">Link</a>`.
However, in these cases it is generally better for accessibility and semantic markup to use a `<button>` element, rather than use a `<a>`.

For accessibility and useability we avoid using links with `target="_blank"` attribute (a [summary of reasons](https://css-tricks.com/use-target_blank/)).
If that attribute is used, you should also include the attribute `rel="noopener"` for [security](https://web.dev/external-anchors-use-rel-noopener/).
For example, `<a href="" target="_blank" rel="noopener">link</a>`.
Target _blank links are currently used for links to JSON files (so they can be viewed in the browser) and Item downloads (since these could be a variety of file types or links).
 