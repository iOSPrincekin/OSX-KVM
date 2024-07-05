HTMLViewController.loadLocalizedStrings();

window.addEventListener("DOMContentLoaded", () => {
    document.documentElement.dir = HTMLViewController.UIString("Text Direction");
    if (pageLoadedExtras)
        pageLoadedExtras();
});

window.addEventListener("load", () => {
    HTMLViewController.pageLoaded();
    webkit.messageHandlers.controller.postMessage("loaded");
});

function editWebsitesButtonClicked()
{
    webkit.messageHandlers.controller.postMessage("editWebsites");
}

function allowAllWebsitesButtonClicked()
{
    webkit.messageHandlers.controller.postMessage("allowAllWebsites");
}

async function developMenuEnabled()
{
    return webkit.messageHandlers.controller.postMessage("developMenuEnabled");
}

async function displayPermissionsAndErrors(websiteAccess, errorStrings, displayName, enabled)
{
    await displayPermissions(websiteAccess, displayName, enabled);
    await displayErrors(errorStrings, displayName);
}

async function displayPermissions(websiteAccess, displayName, enabled)
{
    if (typeof displayPermissionsExtras !== 'undefined')
        displayPermissionsExtras(websiteAccess);

    const webpageContentsSection = document.getElementById("webpageContents");
    const browsingHistorySection = document.getElementById("browsingHistory");
    const trackingInformationSection = document.getElementById("trackingInformation");

    const websiteAccessTitle = document.getElementById("websiteAccessTitle");
    websiteAccessTitle.textContent = "";

    const websiteAccessSection = document.getElementById("websiteAccess");

    if (!websiteAccess) {
        websiteAccessSection.classList.add("hidden");
        return;
    }

    websiteAccessSection.classList.remove("hidden");
    browsingHistorySection.classList.remove("hidden");

    const webpageContentsSubtitle = webpageContentsSection.querySelector(".accessSubtitle");
    webpageContentsSubtitle.textContent = HTMLViewController.UIString("Can read sensitive information from webpages, including passwords, phone numbers, and credit cards. Can alter the appearance and behavior of webpages. This applies on:");

    const browsingHistorySubtitle = browsingHistorySection.querySelector(".accessSubtitle");
    browsingHistorySubtitle.textContent = HTMLViewController.UIString("Can see when you visit:");

    const trackingInformationSubtitle = trackingInformationSection.querySelector(".accessSubtitle");
    trackingInformationSubtitle.textContent = HTMLViewController.UIString("Can send information to webpages you visit, which can be used to track you across:");

    const accessLevel = websiteAccess["Level"];
    if (accessLevel === "All" || accessLevel === "Some") {
        websiteAccessTitle.textContent = HTMLViewController.UIString("Permissions for “%@”:").format(displayName);

        const webpageContentsDomainList = document.getElementById("webpageContentsDomainList");
        const browsingHistoryDomainList = document.getElementById("browsingHistoryDomainList");

        webpageContentsDomainList.innerHTML = "";
        browsingHistoryDomainList.innerHTML = "";

        if (accessLevel === "All") {
            webpageContentsDomainList.classList.add("hidden");
            browsingHistoryDomainList.classList.add("hidden");

            webpageContentsSubtitle.innerHTML = HTMLViewController.UIString("Can read sensitive information from webpages, including passwords, phone numbers, and credit cards. Can alter the appearance and behavior of webpages. This applies on <em>all webpages</em>.");
            browsingHistorySubtitle.innerHTML = HTMLViewController.UIString("Can see when you visit <em>all webpages</em>.");
        } else {
            const allowedDomains = websiteAccess["Allowed Domains"];

            if (allowedDomains.length == 1) {
                webpageContentsDomainList.classList.add("hidden");
                browsingHistoryDomainList.classList.add("hidden");

                webpageContentsSubtitle.innerHTML = HTMLViewController.UIString("Can read sensitive information from webpages, including passwords, phone numbers, and credit cards. Can alter the appearance and behavior of webpages. This applies on <em>%@</em>.").format(allowedDomains[0]);
                browsingHistorySubtitle.innerHTML = HTMLViewController.UIString("Can see when you visit <em>%@</em>.").format(allowedDomains[0]);
            } else {
                webpageContentsDomainList.classList.remove("hidden");
                browsingHistoryDomainList.classList.remove("hidden");

                for (let allowedDomain of allowedDomains) {
                    let allowedDomainListItem = document.createElement("li");
                    allowedDomainListItem.textContent = allowedDomain;

                    webpageContentsDomainList.appendChild(allowedDomainListItem.cloneNode(true));
                    browsingHistoryDomainList.appendChild(allowedDomainListItem.cloneNode(true));
                }
            }
        }

        if (websiteAccess["Has Injected Content"])
            webpageContentsSection.classList.remove("hidden");
        else
            webpageContentsSection.classList.add("hidden");

        const allowedDomainsForHeaderInjection = websiteAccess["Allowed Domains for Header Injection"];
        if (allowedDomainsForHeaderInjection) {
            trackingInformationSection.classList.remove("hidden");

            const trackingInformationDomainList = document.getElementById("trackingInformationDomainList");
            trackingInformationDomainList.innerHTML = "";

            if (allowedDomainsForHeaderInjection.length == 1) {
                trackingInformationDomainList.classList.add("hidden");

                trackingInformationSubtitle.innerHTML = HTMLViewController.UIString("Can send information to webpages you visit, which can be used to track you across <em>%@</em>.").format(allowedDomainsForHeaderInjection[0]);
            } else {
                trackingInformationDomainList.classList.remove("hidden");

                for (let allowedDomain of allowedDomainsForHeaderInjection) {
                    let allowedDomainListItem = document.createElement("li");
                    allowedDomainListItem.textContent = allowedDomain;
                    trackingInformationDomainList.appendChild(allowedDomainListItem);
                }
            }
        } else
            trackingInformationSection.classList.add("hidden");
    } else if (accessLevel === "Discrete") {
        webpageContentsSection.classList.add("hidden");
        trackingInformationSection.classList.add("hidden");
        browsingHistorySection.classList.add("hidden");

        const requestedAccessToCurrentSite = websiteAccess["Requested Current Site"];
        const requestedSiteAccess = websiteAccess["Requested Sites"];
        const configuredSiteAccess = websiteAccess["Configured Sites"];

        const addBlankLine = (element) => {
            element.appendChild(document.createElement("br"));
            element.appendChild(document.createElement("br"));
        };

        const hasNoAccess = !requestedAccessToCurrentSite && configuredSiteAccess === "None";
        websiteAccessTitle.appendChild(document.createTextNode(HTMLViewController.UIString("Permissions for “%@”:").format(displayName)));

        let accessCategory;

        if (configuredSiteAccess === "All") {
            accessCategory = websiteAccessTitle;

            addBlankLine(websiteAccessTitle);

            const warningElement = document.createElement("div");
            warningElement.className = "warningBanner";

            const headerElement = document.createElement("h1");
            headerElement.textContent = HTMLViewController.UIString("This extension can read and alter webpages you visit and see your browsing history on all websites.");
            warningElement.appendChild(headerElement);

            const warningBodyTextNode = document.createTextNode(HTMLViewController.UIString("This includes sensitive information from webpages, including passwords, phone numbers, and credit cards."));
            warningElement.appendChild(warningBodyTextNode);

            websiteAccessTitle.appendChild(warningElement);

            websiteAccessTitle.appendChild(document.createTextNode(HTMLViewController.UIString("You can change this in Safari Websites preferences.")));
            websiteAccessTitle.appendChild(document.createElement("br"));
        } else if (!hasNoAccess) {
            accessCategory = document.createElement("div");
            accessCategory.classList.add("accessCategory");

            const accessTitle = document.createElement("div");
            accessTitle.classList.add("accessTitle");
            accessTitle.textContent = HTMLViewController.UIString("Webpage Contents and Browsing History");
            accessCategory.appendChild(accessTitle);

            const requestsMultiplePermissions = configuredSiteAccess instanceof Array && ((requestedAccessToCurrentSite && configuredSiteAccess.length >= 1) || configuredSiteAccess.length >= 2);

            const accessSubtitle = document.createElement("div");
            accessSubtitle.classList.add("accessSubtitle");
            accessSubtitle.id = "webpageContentsAndBrowsingHistorySubtitle";
            accessCategory.appendChild(accessSubtitle);

            if (requestsMultiplePermissions) {
                accessSubtitle.textContent = HTMLViewController.UIString("Can read and alter sensitive information on webpages, including passwords, phone numbers, and credit cards, and see your browsing history on:");

                const sitesList = document.createElement("ul");
                if (requestedAccessToCurrentSite) {
                    let listItem = document.createElement("li");
                    listItem.appendChild(document.createTextNode(HTMLViewController.UIString("the current tab’s webpage when you use the extension")));
                    sitesList.appendChild(listItem);
                }

                if (configuredSiteAccess instanceof Array) {
                    for (let configuredSite of configuredSiteAccess) {
                        let listItem = document.createElement("li");
                        listItem.textContent = configuredSite;
                        sitesList.appendChild(listItem);
                    }
                }

                accessCategory.appendChild(sitesList);
            } else {
                if (requestedAccessToCurrentSite)
                    accessSubtitle.innerHTML = HTMLViewController.UIString("Can read and alter sensitive information on webpages, including passwords, phone numbers, and credit cards, and see your browsing history on <em>the current tab’s webpage when you use the extension</em>.");
                else if (configuredSiteAccess instanceof Array)
                    accessSubtitle.innerHTML = HTMLViewController.UIString("Can read and alter sensitive information on webpages, including passwords, phone numbers, and credit cards, and see your browsing history on <em>%@</em>.").format(configuredSiteAccess[0]);
            }

            websiteAccessTitle.appendChild(accessCategory);
        } else {
            accessCategory = document.createElement("div");
            accessCategory.classList.add("accessCategory");

            const accessTitle = document.createElement("div");
            accessTitle.classList.add("accessTitle");
            accessTitle.textContent = HTMLViewController.UIString("Webpage Contents and Browsing History");
            accessCategory.appendChild(accessTitle);

            const accessSubtitle = document.createElement("div");
            accessSubtitle.classList.add("accessSubtitle");
            accessSubtitle.id = "webpageContentsAndBrowsingHistorySubtitle";
            accessCategory.appendChild(accessSubtitle);

            accessSubtitle.appendChild(document.createTextNode(HTMLViewController.UIString("When you use the “%@” toolbar button, the extension may request access to read and alter webpages and to see your browsing history. Granting access may be required for the extension to function.").format(displayName)));
            addBlankLine(accessSubtitle);
            accessSubtitle.appendChild(document.createTextNode(HTMLViewController.UIString("You have not allowed this extension on any websites yet.")));

            websiteAccessTitle.appendChild(accessCategory);
        }

        if (requestedSiteAccess !== "None") {
            const editWebsitesButton = document.createElement("button");
            editWebsitesButton.addEventListener("click", editWebsitesButtonClicked, false);
            editWebsitesButton.textContent = HTMLViewController.UIString("Edit Websites…");
            editWebsitesButton.disabled = !enabled;

            accessCategory.appendChild(document.createElement("br"));
            accessCategory.appendChild(editWebsitesButton);
        }

        if (requestedSiteAccess === "All" && configuredSiteAccess !== "All") {
            const allowAllWebsitesButton = document.createElement("button");
            allowAllWebsitesButton.addEventListener("click", allowAllWebsitesButtonClicked, false);
            allowAllWebsitesButton.textContent = HTMLViewController.UIString("Always Allow on Every Website…");
            allowAllWebsitesButton.disabled = !enabled;

            accessCategory.appendChild(allowAllWebsitesButton);
        }
    } else {
        browsingHistorySection.classList.add("hidden");
        webpageContentsSection.classList.add("hidden");
        trackingInformationSection.classList.add("hidden");

        if (accessLevel === "NoneForContentBlocker")
            websiteAccessTitle.textContent = HTMLViewController.UIString("“%@” does not have permission to read or transmit content from any webpages.").format(displayName);
        else {
            if (websiteAccess["Override Page"])
                websiteAccessTitle.textContent = HTMLViewController.UIString("Permissions for “%@”:").format(displayName);
            else
                websiteAccessTitle.textContent = HTMLViewController.UIString("“%@” does not have permission to read, alter, or transmit content from any webpages.").format(displayName);
        }
    }
}

async function displayErrors(errorStrings, displayName)
{
    const errorSection = document.getElementById("errors");
    errorSection.textContent = "";

    if (!errorStrings || !errorStrings.length) {
        errorSection.classList.add("hidden");
        return;
    }

    errorSection.classList.remove("hidden");

    if (!await developMenuEnabled()) {
        // Show something if the website access section is hidden, otherwise the pane will be empty.
        const websiteAccessSection = document.getElementById("websiteAccess");
        if (websiteAccessSection.classList.contains("hidden"))
            errorSection.textContent = HTMLViewController.UIString("“%@” is not supported by this version of Safari or encountered an error.").format(displayName);
        return;
    }

    const errorHeader = document.createElement("div");
    errorHeader.textContent = HTMLViewController.UIString("Errors for “%@”:").format(displayName);
    errorSection.appendChild(errorHeader);

    const errorList = document.createElement("ul");

    const formatError = (string) => {
        const mapping = {
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;"
        };

        return string.replace(/[&<>]/g, (match) => { return mapping[match] || match }).replace(/`(.*?)`/g, "<code>$1</code>");
    };

    for (let errorString of errorStrings) {
        let errorItem = document.createElement("li");
        errorItem.innerHTML = formatError(errorString);
        errorList.appendChild(errorItem);
    }

    errorSection.appendChild(errorList);
}
