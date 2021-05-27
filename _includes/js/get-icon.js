/* 
    get a theme icon based on object_template or format 
    return svg sprite
*/
function getIcon(objectTemplate,objectFormat) {
    var iconId;
    // avoid errors if no format
    if (!objectFormat) { objectFormat = "" }
    // choose icon
    if (objectTemplate == "image" || objectFormat.includes("image")) {
        iconId = "icon-image";
    } else if (objectTemplate == "pdf" || objectFormat.includes("pdf")) {
        iconId = "icon-pdf";
    } else if (objectTemplate == "video" || objectTemplate == "video-embed" || objectFormat.includes("video")) {
        iconId = "icon-video";
    } else if (objectTemplate == "audio" || objectFormat.includes("audio")) {
        iconId = "icon-audio";
    } else {
        iconId = "icon-default";
    }
    // svg sprite as thumb
    return '<svg class="bi text-body" fill="currentColor"><use xlink:href="{{ "/assets/lib/cb-icons.svg" | relative_url }}#' + iconId + '"/></svg>';
}