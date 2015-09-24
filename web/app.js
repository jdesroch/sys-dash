var init = function(){
    data.init();
    view.init();
};

var data = {
    Result: {
        PASS: 1,
        FAIL: 2,
        ERROR: 3
    },
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
    getItemsByTag: function(tag){
        var i, ilen = data.items.length, item, tagItems = [];
        for(i=0;i<ilen;i++){
            item = data.items[i];
            if(item.tags.indexOf(tag) >= 0){
                tagItems.push(item);
            }
        }
        return taItems;
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
        defaultLink: document.getElementById("nav-zones"),
        getTab: function(link) {
            return document.getElementById(link.id.replace("nav-", ""));
        },
        select: function(selectedLink) {
            var i, len = view.Nav.links.length,
                link;
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
        },
        init: function() {
            view.Nav.root = document.getElementById("main-nav");
            view.Nav.links = view.Nav.root.querySelectorAll("a");
            view.Nav.root.addEventListener("click", function(event) {
                view.Nav.select(event.target);
            }, true);
            
            view.Nav.select(view.Nav.defaultLink);
        }
    },
    OverviewTab: {
        root: document.getElementById("overview"),
        init: function(){
            view.OverviewTab.root.innerHTML = "TEST CONTENT";
        }
    },
    ZoneTab : {
        root: document.getElementById("zones"),
        init: function() {
            view.ZoneTab.root.innerHTML = "";
            view.ZoneTab.root.appendChild(document.createElement("br"));
            
            var table = document.createElement('table');
    
            // Header is list of zones
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
                zheader.addEventListener("click", view.ZoneTab.onZoneClick);
            }
            // One row per item
            var i, ilen = data.items.length,
                item, row, cell, result, status;
            for (i = 0; i < ilen; i++) {
                item = data.items[i];
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
                        cell.addEventListener("click", view.ZoneTab.onResultClick);
                    }
                }
            }
            view.ZoneTab.root.appendChild(table);
            
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
        }
    },
    FunctionalTab: {
        root: document.getElementById("functions"),
        init: function(){
            view.FunctionalTab.root.innerHTML = "TEST CONTENT";}
    },
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
    init: function() {
        for(var widget in view){
            if(widget != "init")
                view[widget].init();
        }
    }
};