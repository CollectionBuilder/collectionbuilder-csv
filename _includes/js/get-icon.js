/* 
    get a theme icon based on display_template or format 
    return svg sprite
*/
function getIcon(objectTemplate,objectFormat) {
    var iconTemplate, iconId;
    if (objectTemplate && objectTemplate != "") {
        iconTemplate = objectTemplate;
    } else if (objectFormat && objectFormat != "") {
        iconTemplate = objectFormat;
    } else {
        iconTemplate = ""
    }
    // choose icon
    if (iconTemplate.includes("image")) {
        iconId = "icon-image";
    } else if (iconTemplate.includes("pdf")) {
        iconId = "icon-pdf";
    } else if (iconTemplate.includes("video")) {
        iconId = "icon-video";
    } else if (iconTemplate.includes("audio")) {
        iconId = "icon-audio";
    } else {
        iconId = "icon-default";
    }
    // svg sprite as thumb
    return '<svg class="bi text-body" fill="currentColor"><use xlink:href="{{ "/assets/lib/cb-icons.svg" | relative_url }}#' + iconId + '"/></svg>';
}