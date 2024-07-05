async function pageLoadedExtras()
{
    var htmlString = '<div id="overridePage" class="accessCategory"> <div class="accessTitle l12n">New Windows and Tabs Page</div> <div class="accessSubtitle l12n">Can be used as a new window or tab page.</div> </div>'
    var element = document.createElement("div");

    var websiteAccessSection = document.getElementById("websiteAccess");
    websiteAccessSection.appendChild(element);

    element.outerHTML = htmlString;
}

async function displayPermissionsExtras(websiteAccess)
{
    var overridePageSection = document.getElementById("overridePage");
    const isOverridePageRequested = websiteAccess ? websiteAccess["Override Page"] : false;
    if (isOverridePageRequested)
        overridePage.classList.remove("hidden");
    else
        overridePage.classList.add("hidden");
}
