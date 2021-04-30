# Foot

All js is loaded at the bottom of the page in "foot.html" include.
First, jquery and bootstrap bundle are loaded, then any other sections based on page layout or other front matter.
This ensures js is loaded in order and is optimized for page load.

# Links

For security and performance reasons all links with `target="_blank"` attribute should also have the attribute `rel="noopener"`.
For example, `<a href="" target="_blank" rel="noopener">link</a>`

See https://web.dev/external-anchors-use-rel-noopener/

We use Bootstrap button classes to style many of our links. 
If they are actual links, i.e. go to a different page or to an anchor on the page, they should NOT have the attribute `role="button"` since this can trigger odd rendering and unnecessary screen reader interactions. 
For example, `<a class="btn btn-primary" href="https://example.com">Link</a>`.

If `<a>` tags are used to trigger interactivity on the page, for example opening a modal, then they SHOULD have `role="button"` for accessibility purposes. 
For example, `<a class="btn btn-primary" href="#" role="button" data-toggle="modal" data-target="#exampleModal">Link</a>`.
In these cases it might make more sense to replace the `<a>` with a `<button>` element.
