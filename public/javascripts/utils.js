

function validateNumber(event) {
    var key = window.event ? event.keyCode : event.which;

    if (event.keyCode == 8 || event.keyCode == 46
        || event.keyCode == 37 
        || event.keyCode == 39
        || event.keyCode == 13
        || event.keyCode == 10) {
        return true;
    }
    else if ( key < 48 || key > 57 ) {
        return false;
    }
    else return true;
};

function loadjs(filename) {
    var fileref = document.createElement('script')
    fileref.setAttribute("type","text/javascript")
    fileref.setAttribute("src", filename)
    document.getElementsByTagName("head")[0].appendChild(fileref)
}

function mysqlTimeStampToDate(timestamp) {
    //function parses mysql datetime string and returns javascript Date object
    //input has to be in this format: 2007-06-05 15:26:02
    var regex=/^([0-9]{2,4})-([0-1][0-9])-([0-3][0-9]) (?:([0-2][0-9]):([0-5][0-9]):([0-5][0-9]))?$/;
    var parts = timestamp.replace(regex,"$1 $2 $3 $4 $5 $6").split(' ');
    return new Date(parts[0],parts[1]-1,parts[2],parts[3],parts[4],parts[5]);
}


document.onmousemove = getMouseXY;
var currentMouseX = 0;
var currentMouseY = 0;

function getMouseXY(e) {
    var tempX = 0;
    var tempY = 0;
    if ((!this.opera && /msie/i.test(navigator.userAgent.toLowerCase()))) { // grab the x-y pos.s if browser is IE
        tempX = event.clientX + document.body.scrollLeft
        tempY = event.clientY + document.body.scrollTop
    } else {  // grab the x-y pos.s if browser is NS
        tempX = e.pageX
        tempY = e.pageY
    }
    // catch possible negative values in NS4
    if (tempX < 0){
        tempX = 0
    }
    if (tempY < 0){
        tempY = 0
    }

    currentMouseX = tempX;
    currentMouseY = tempY;
}

function openExternalScroll (address) {
    var external = window.open(address.replace(/\+/g,"%2B"), "paymentglobal", "width=840, height=680,left=100,top=200,scrollbars=yes");
    external.focus();

}
