var init = function(){
    data.init();
    view.init();
};

var data = {
    Result: {
        PASS: "pass",
        FAIL: "fail",
        ERROR: "error"
    },
    ALL_ITEMS: "All Items",
    init: function() {
        data.items = sysdata.items || [];
        data.results = sysdata.results || [];
        data.zones = sysdata.zones || [];
        data.tags = sysdata.tags || [];
    },
    getItem: function(ID){
        var i, ilen = data.items.length, item;
        for(i=0;i<ilen;i++){
            item = data.items[i];
            if(item.ID === ID){
                return item;
            }
        }
        return null;
    },
    getItemNameSpaces: function(item){
        var names = item.ID.split('_'), namespaces = {};
        for(var i=0; i<names.length; i++){
            namespaces.push(
                i > 0 ? names[i-1] + "_" + names[i] :   names[i]);
        }
    },
    getItemsByTag: function(tag){
        var i, ilen = data.items.length, item, tagItems = [];
        for(i=0;i<ilen;i++){
            item = data.items[i];
            if(item.tags.indexOf(tag) >= 0){
                tagItems.push(item);
            }
        }
        return tagItems;
    },
    getAggregateStatus: function(items, zone){
        var i, ilen = items.length, status="pass";
        for (i=0; i<ilen; i++){
            switch(data.getResultByZone(items[i], zone)) {
                case "fail":
                    status="fail";
                    break;
                case "error":
                    return "error";
                default:
            }
        }
        return status;
    },
    getTagStatus: function(tag, zone){
        return data.getAggregateStatus(data.getItemsByTag(tag), zone);
    },
    getResultByZone: function(item, zoneName) {
        var r, rlen = data.results.length, result;
        for(r=0;r<rlen;r++){
            result = data.results[r];
            if(item.ID === result.itemID && result.zone === zoneName)
                return result;
        }
        return null;
    },
    getZoneStatus: function(zoneName){
        var z, zlen = data.zones.length, zone;
        for(z=0; z<data.zones.length; z++){
            if(data.zones[z].name == zoneName){
                return data.zones[z].status;
            }
        }
    }
};

var view = {
    Nav: {
        defaultLink: document.getElementById("nav-overview"),
        getTab: function(link) {
            return document.getElementById(link.id.replace("nav-", ""));
        },
        select: function(selectedLink) {
            var i, len = view.Nav.links.length, link;
            for (i = 0; i < len; i++) {
                link = view.Nav.links[i];
                if (link == selectedLink) {
                    addClass(link, "active");
                    show(view.Nav.getTab(link));
                } else {
                    removeClass(link, "active");
                    hide(view.Nav.getTab(link));
                }
            }
            view.Detail.reset();
            // Store across browser refreshes
            localStorage.setItem("selectedNavLink", selectedLink.id);
        },
        init: function() {
            view.Nav.root = document.getElementById("main-nav");
            view.Nav.links = view.Nav.root.querySelectorAll("a");
            view.Nav.root.addEventListener("click", function(event) {
                view.Nav.select(event.target);
            }, true);
                
                // TODO: Select anchor element...
            var selectedLink = document.getElementById(localStorage.getItem("selectedNavLink"));
            view.Nav.select(selectedLink || view.Nav.defaultLink);
        }
    },
    OverviewTab: {
        root: document.getElementById("overview"),
        init: function(){
            view.OverviewTab.root.innerHTML = "";
            view.OverviewTab.root.appendChild(document.createElement("br"));
            // Tag filter
            var tagselector = document.createElement("select");
            tagselector.id = "tagselector";
            var tlen = data.tags.length, t, option;
            option = document.createElement("option");
            option.value = data.ALL_ITEMS;
            option.innerHTML = data.ALL_ITEMS;
            tagselector.appendChild(option);
            for(t=0;t<tlen; t++){
                option = document.createElement("option");
                option.value = data.tags[t];
                option.innerHTML = data.tags[t];
                tagselector.appendChild(option);
            }
            view.OverviewTab.root.appendChild(tagselector);
            tagselector.addEventListener("change", view.OverviewTab.onChangeTag);
            view.OverviewTab.root.appendChild(document.createElement("br"));
            
            var itemTableDiv = document.createElement("div");
            itemTableDiv.id = "itemTableDiv";
            view.OverviewTab.root.appendChild(itemTableDiv);
            
            // Initially all items are shown
            view.appendItemTable(itemTableDiv, data.items);
            
        },
        // Filter items shown in table
        onChangeTag: function(){
            var selectedTag = document.getElementById("tagselector").value;
            var itemTableDiv = document.getElementById("itemTableDiv");
            itemTableDiv.innerHTML = "";
            if(selectedTag === data.ALL_ITEMS)
                view.appendItemTable(itemTableDiv, data.items);
            else
                view.appendItemTable(itemTableDiv, data.getItemsByTag(selectedTag));
        }
    },
    /**
    ZoneTab : {
        root: document.getElementById("zones"),
        init: function() {
            view.ZoneTab.root.innerHTML = "";
            view.ZoneTab.root.appendChild(document.createElement("br"));
            view.appendItemTable(view.ZoneTab.root, data.items);
        }
    },
    FunctionalTab: {
        root: document.getElementById("functions"),
        init: function(){
            view.FunctionalTab.root.innerHTML = "";
            view.FunctionalTab.root.appendChild(document.createElement("br"));
            var t, tlen = data.tags, tagHeader;
            for(t=0; t<tlen; t++){
                tagHeader = document.createElement("h2");
                tagHeader.innerHTML(data.tags[t]);
                view.FunctionalTab.root.appendChild(tagHeader);
                view.appendItemTable(view.FunctionalTab.root, data.getItemsByTag(data.tags[t]));
            }
        }
    },
    **/
    Detail: {
        textarea: document.getElementById("detail-text-area"),
        init: function() {
            view.Detail.reset();
            view.Detail.showSelected();
        },
        setText: function(text) {
            view.Detail.textarea.innerHTML = text;
            view.Detail.textarea.rows = text.split(/\r\n|\r|\n/).length;

            show(view.Detail.textarea);
        },
        showSelected: function() {
            var itemID = localStorage.getItem("selectedItemID");
            var zone = localStorage.getItem("selectedZone");
            if( hasValue(itemID) && hasValue(zone) ){
                var item = data.getItem(itemID),
                    result = data.getResultByZone(item, zone),
                    text = "",
                    prop;
                text += "Item:";
                for (prop in item){
                        text += "\n\t" + prop + ":\t" + item[prop];
                }
                text += "\nResult:";
                for (prop in result){
                    if(prop != "itemID")
                        text += "\n\t" + prop + ":\t" + result[prop];
                }
                view.Detail.setText(text);
            } 
            else if(hasValue(zone)) {
                var status = data.getZoneStatus(zone);
                switch (status) {
                    case 'online':
                        view.Detail.setText(
                            "Zone " + zone + " passed all checks and appears to be online");
                        break;
                    case 'degraded':
                        view.Detail.setText(
                            "Zone " + zone + " failed at least one check but appears to be online");
                        break;
                    case 'offline':
                        view.Detail.setText(
                            "Zone " + zone + " had an error in at least one check and may be offline");
                        break;
                    default:
                        // code
                }
                
            }
        },
        reset: function() {
            view.Detail.setText("");
            hide(view.Detail.textarea);
        }
    },
    appendItemTable: function(parentElement, items) {
             
            var table = document.createElement('table');
    
            // Header list of zones starting a 2nd cell
            var header = table.createTHead();
            var hrow = header.insertRow(0);
            insertHeaderCell(hrow, "Item Name", "header");
            var z, zlen = data.zones.length,
                zone, zoneCells = [];
            for (z = 0; z < zlen; z++) {
                zone = data.zones[z];
                zheader = insertHeaderCell(hrow, zone.name, "header");
                zheader.id = zone.name;
                addClass(zheader, zone.status);
                addClass(zheader, "has-details");
                zheader.addEventListener("click", view.onZoneClick);
            }
            // One row per item
            var i, ilen = items.length,
                item, row, cell, result, status;
            for (i = 0; i < ilen; i++) {
                item = items[i];
                row = table.insertRow(i + 1);
                row.insertCell(0).innerHTML = item.title;
                for (z = 0; z < zlen; z++) {
                    zone = data.zones[z].name;
                    cell = row.insertCell(z + 1);
                    result = data.getResultByZone(item, zone);
                    if (result === null) {
                        addClass(cell, "not-applicable"); //Item does not apply
                        //cell.innerHTML = "not applicable"; 
                    } else {
                        status = result.status || "status-not-found";
                        //cell.innerHTML = status;
                        addClass(cell, status);
                        addClass(cell, "has-details");
                        cell.itemID = item.ID;
                        cell.zone = result.zone;
                        cell.addEventListener("click", view.onResultClick);
                    }
                }
            }
            parentElement.appendChild(table);
    },
    onResultClick: function(event)  {
        localStorage.setItem("selectedItemID", event.target.itemID);
        localStorage.setItem("selectedZone", event.target.zone);
        view.Detail.showSelected();
    },
    onZoneClick: function(event) {
        localStorage.setItem("selectedItemID", "");
        localStorage.setItem("selectedZone", event.target.id);
        view.Detail.showSelected();
    },
    init: function() {
        for(var widget in view){
            if(view[widget].init)
                view[widget].init();
        }
    }
};