/* 
    get a theme icon based on display_template or format 
    return svg sprite
*/
function getIcon(objectTemplate,objectFormat,svgType) {
    var iconTemplate, iconId, iconTitle;
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
        iconTitle = "image file icon";
    } else if (iconTemplate.includes("pdf")) {
        iconId = "icon-pdf";
        iconTitle = "pdf file icon";
    } else if (iconTemplate.includes("video")) {
        iconId = "icon-video";
        iconTitle = "video file icon";
    } else if (iconTemplate.includes("audio")) {
        iconId = "icon-audio";
        iconTitle = "audio file icon";
    } else if (iconTemplate.includes("panorama")) {
        iconId = "icon-panorama";
        iconTitle = "panorama file icon";
    } else if (iconTemplate.includes("compound")) {
        iconId = "icon-compound-object";
        iconTitle = "compound object icon";
    } else if (iconTemplate.includes("multiple")) {
        iconId = "icon-multiple";
        iconTitle = "multiple object icon";
    } else {
        iconId = "icon-default";
        iconTitle = "file icon";
    }
    if (svgType == "thumb") {
        // svg sprite as thumb
        return '<svg class="bi text-body" fill="currentColor" role="img"><title>' + iconTitle + '</title><use xlink:href="{{ "/assets/lib/cb-icons.svg" | relative_url }}#' + iconId + '"/></svg>';
    } else if (svgType == "hidden") {
        // svg as sprite with aria-hidden
        return '<svg class="bi icon-sprite" aria-hidden="true"><use xlink:href="{{ "/assets/lib/cb-icons.svg" | relative_url }}#' + iconId + '"/></svg>';
    } else {
        // svg as sprite
        return '<svg class="bi icon-sprite" aria-label="' + iconTitle + '"><use xlink:href="{{ "/assets/lib/cb-icons.svg" | relative_url }}#' + iconId + '"/></svg>';
    }
}
