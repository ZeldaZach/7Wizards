var Locker = {
    
    lockAttribute:"locked",

    isGlobalLock:false,

    unlockTimeOut:2000,

    lock: function(element, ignoredClass) {
        if(element.hasClassName(ignoredClass)) return;

        if(!element.isLocked()) {
            element.setAttribute(Locker.lockAttribute, "yes");
            
            if(element.tagName.toLowerCase() == "form")
            {
                element.setLockForm(true);
                element.observe('submit', Locker.navigateUrl);
                
            } else if (element.tagName.toLowerCase() == "a") {
                element.setLockLink(true);
                element.observe('dblclick', Locker.navigateUrl);
                element.observe('click', Locker.navigateUrl);
            }

        }
    },

    unlock: function(element) {
        if(element.isLocked()) {
            element.removeAttribute(Locker.lockAttribute);
            
            if(element.tagName.toLowerCase() == "form")
            {
                element.setLockForm(false);
                element.stopObserving('submit', Locker.navigateUrl);
            } else if (element.tagName.toLowerCase() == "a") {
                element.setLockLink(false);
                element.stopObserving('click', Locker.navigateUrl);
                element.stopObserving('dblclick', Locker.navigateUrl);
            }

        }
    },

    setLockLink: function(element, value) {
        if(element.onclick && value)
        {
            //link with onclick
            element.onclick = new Function("return false;" + element.onclick.toString().getFuncBody());

        } else if(!element.onclick && value) {

            //link without onclick
            element.onclick = function() {
                return false;
            }
            
        } else if(element.onclick.toString().indexOf("function() {return false;}") != -1){
            
            element.onclick = null;

        } else if(element.onclick && !value) {

            var func = element.onclick.toString().getFuncBody().replace("return false;", "");
            element.onclick = new Function(func);

        }
    },

    setLockForm: function(element, value) {

        if(value && element.onsubmit)
        {
            element.onsubmit = new Function("return false;" + element.onsubmit.toString().getFuncBody());
        } else if (!value && element.onsubmit)
{
            element.onsubmit = element.onsubmit.toString().getFuncBody().replace("return false;", "");
        }
    },

    isLocked: function(element) {
        return element.hasAttribute(Locker.lockAttribute) &&
        element.getAttribute(Locker.lockAttribute) == "yes";
    },

    clearLockStatus: function() {
        Locker.isGlobalLock = false;
        window.clearTimeout(Locker.timeoutId);
    },

    navigateUrl: function(event) {
        var element = event.currentTarget;

        if (Locker.isGlobalLock) {
            return;
        } else {
            
            Locker.isGlobalLock = true;

            Locker.timeoutId = window.setTimeout(function(){
                Locker.isGlobalLock = false;
            }, Locker.unlockTimeOut);
        }
        
        if (event.currentTarget.tagName.toLowerCase() == "form")
        {
            eval(event.currentTarget.onsubmit.toString().getFuncBody().replaceAll("return false;",""));
        } else  if (element.onclick) {
            eval(element.onclick.toString().getFuncBody().replaceAll("return false;",""));
            location.href = element.getAttribute("href");
        }
    }
}

Element.addMethods(Locker);

Array.prototype.lock = function(ignoredClass) {
    for (var i = 0, length = this.length; i < length; i++) {
        this[i].lock(ignoredClass);
    }
}

Array.prototype.remove = function() {
    for (var i = 0, length = this.length; i < length; i++) {
        this[i].remove();
    }
}

String.prototype.getFuncBody = function(){
    var str = this.toString();
    str = str.replace(/[^{]+{/, "");
    str = str.substring(0, str.length-1);
    str = str.replace(/\n/gi, "");
    //if(!str.match(/\(.*\)/gi))str;
    return str;
}

String.prototype.replaceAll = function(from, to){
    var i = this.indexOf(from);
    var c = this;

    while (i > -1){
        c = c.replace(from, to);
        i = c.indexOf(from);
    }
    return c;
}

var ImageTag = Class.create({
    initialize: function(i_url, attributes) {
        attributes = attributes || {};
        attributes.src = ImageTag.imgUrl(i_url);
        this.element = new Element("img", attributes);
    },

    src: function(i_url) {
        this.element.src = ImageTag.imgUrl(i_url);
    },

    toElement: function() {
        return this.element;
    }
});

ImageTag.imgUrl = function(img) {
    if(img[0] != "/") {
        img = "/images/design/" + img;
    }
    return img
}




/* Usage: var p = new Flog.UriParser('http://user:password@flog.co.nz/pathname?arguments=1#fragment');
 * p.host == 'flog.co.nz';
 * p.protocol == 'http';
 * p.pathname == '/pathname';
 * p.querystring == 'arguements=1';
 * p.querystring.params[arguements] | p.querystring.params.arguements == 1
 * p.fragment == 'fragment';
 * p.user == 'user';
 * p.password == 'password';
 *
 */

/* Fake a Flog.* namespace */
if(typeof(Flog) == 'undefined') var Flog = {};

Flog.UriParser = Class.create();


Flog.UriParser.prototype = {
    _regExp : /^((\w+):\/\/)?((\w+):?(\w+)?@)?([^\/\?:]+):?(\d+)?(\/?[^\?#]+)?\??([^#]+)?#?(\w*)/,
    username : null,
    password : null,
    port : null,
    protocol : null,
    host : null,
    pathname : null,
    url : null,
    querystring : {},
    fragment : null,

    initialize: function(uri) {
        if(uri) this.parse(uri);
    },

    _getVal : function(r, i) {
        if(!r) return null;
        return (typeof(r[i]) == 'undefined' ? null : r[i]);
    },

    _rebuild: function() {
        var u = "";
        if(this.protocol) u += this.protocol + "://";
        if(this.username) u += this.username;
        if(this.password) u += ":"+this.password;
        if(this.host)     u += this.host;
        if(this.port)     u += ":"+this.port;
        if(this.pathname) u += this.pathname;
        if(this.querystring.length > 0 ) u += "?"+this.querystring.toString();
        if(this.fragment) u += "#"+this.fragment;

        return u
    },

    parse: function(uri) {
        var r = this._regExp.exec(uri);
        if (!r) throw "FlogUriParser::parse -> Invalid URI"
        this.url	 = this._getVal(r,0);
        this.protocol	 = this._getVal(r,2);
        this.username	 = this._getVal(r,4);
        this.password	 = this._getVal(r,5);
        this.host	 = this._getVal(r,6);
        this.port	 = this._getVal(r,7);
        this.pathname	 = this._getVal(r,8);
        this.querystring = new Flog.UriParser.QueryString(this._getVal(r,9));
        this.fragment	 = this._getVal(r,10);
        return r;
    },

    addParam: function(p, v) {
        this.querystring.add(p, v);
        this.url = this._rebuild();
    }
};

/* Querystring sub class */
Flog.UriParser.QueryString = Class.create();
Flog.UriParser.QueryString.prototype = {
    rawQueryString : '',
    length : 0,
    params:null,
    initialize : function(qs) {

        this.params = {};

        if(!qs) {
            this.rawQueryString = '';
            this.length = 0;
            return;
        }
        this.rawQueryString = qs;
        var args = qs.split('&');
        this.length = args.length;
        
        for (var i=0;i<args.length;i++) {
            var pair = args[i].split('=');
            this.params[unescape(pair[0])] = ((pair.length == 2) ? unescape(pair[1]) : pair[0]);
        }
    },

    add: function(p, v) {
        if(typeof(this.params[unescape(p)]) == 'undefined') {
            this.length++;
        }
        
        this.params[unescape(p)] = unescape(v);

        this.rawQueryString = '';
        for(var pr in this.params) {
            this.rawQueryString += pr + "=" + this.params[pr] + "&";
        }
    },
    
    toString : function() {
        return this.rawQueryString;
    }
};
