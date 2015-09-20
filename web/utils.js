// hasClass, takes two params: element and classname
function hasClass(el, cls) {
  return el.className && new RegExp("(\\s|^)" + cls + "(\\s|$)").test(el.className);
}

// addClass, takes two params: element and classname
function addClass(el, cls) {
    if(!hasClass(el, cls)) {
        if(el.className)
            el.className += " " + cls;
        else
            el.className += cls;
    }
}

// removeClass, takes two params: element and classname
function removeClass(el, cls) {
    if(hasClass(el, cls)) {
        var reg = new RegExp("(\\s|^)" + cls + "(\\s|$)");
        el.className = el.className.replace(reg, " ").replace(/(^\s*)|(\s*$)/g,"");
    }
}

function toggleClass(el, cls) {
    if(hasClass(el, cls))
        removeClass(el, cls);
    else
        addClass(el, cls);
}

function show(el){
    removeClass(el, "hidden");
    addClass(el, "visible");
}

function hide(el){
    removeClass(el, "visible");
    addClass(el, "hidden");
}

function toggleDisplay(el) {
    if(hasClass(el, "hidden") || !hasClass(el, "visible"))
        show(el);
    else if(!hasClass(el, "hidden") || hasClass(el, "visible"))
        hide(el);
}

// Tables
function insertHeaderCell(row, cellText, cellClass){
    var cell = document.createElement('th');
    cell.innerHTML = cellText;
    addClass(cellClass);
    row.appendChild(cell);
}