//FIX PERMISSION DENIED FOR FRAMES
document.domain = document.domain;

var ajax_mode = true;

var urlHelper = {
    getPort: function() {
        return location.port ? ":" + location.port : ""
    },
    baseUrl: function() {
        return "http://"+document.domain + this.getPort()
    },
    loginUrl:function() {
        return this.baseUrl()+"/login"
    },

    logout: function() {
        return this.baseUrl()+"/logout"
    },
    
    homeUrl: function() {
        return this.baseUrl()+"/home/index_ajax"
    },
    
    profileUrl: function() {
        return this.baseUrl()+"/profile/index"
    },

    getAddThisUrl: function() {
        return "http://s7.addthis.com/js/250/addthis_widget.js#username=7wizards";
    }

}
var _ua = navigator.userAgent.toLowerCase();
var intervals = {};

//var browser = {
//    version: (_ua.match( /.+(?:me|ox|on|rv|it|ra|ie)[\/: ]([\d.]+)/ ) || [0,'0'])[1],
//    opera: /opera/i.test(_ua),
//    msie: (!this.opera && /msie/i.test(_ua)),
//    msie6: (!this.opera && /msie 6/i.test(_ua)),
//    msie8: (!this.opera && /msie 8/i.test(_ua)),
//    mozilla: /firefox/i.test(_ua),
//    chrome: /chrome/i.test(_ua),
//    safari: (!(/chrome/i.test(_ua)) && /webkit|safari|khtml/i.test(_ua)),
//    iphone: /iphone/i.test(_ua)
//}



function navigate(url, callback, async, force_ajax) {
    if(async == null) async = true;
    if(force_ajax == null) force_ajax = false;
    if(ajax_mode || force_ajax) {
        new Ajax.Request(url, {
            asynchronous:async,
            evalScripts:true,
            onLoaded:function(request){
                javascript: wizards.onCallback();
            if(Object.isFunction(callback)) {
                callback.call(this, request);
            }
            },
            onLoading:function(request){
                showLoader();
                setTimeout(function(){
                    hideLoader()
                }, 5000);
            }
        });
    } else {
        window.location = url;
    }
}

function navigateToLogin() {
    window.location = urlHelper.loginUrl();
}

//this function called by flash
function fight_result(id, is_dragon)
{
    var url;
    if(is_dragon) {
        url = "/dragon";
    } else {
        url = "/fight";
    }

    url += "/fight_result/" + id;
    
    navigate(url,null,null,true)
    
}

function setDescription(text) {
    $('new_dragon_desc').innerHTML = text;
}

function notice_error(error)
{
    var div = "<div class='rounded' style='background-color: red'>"+error+"</div>"
    $("notification").innerHTML = div;
    wizards.onNoticeScroll();
}

function flashMovie(movieName) {
    if (navigator.appName.indexOf("Microsoft") != -1) {
        return window[movieName];
    }else {
        return document[movieName];
    }
}

function load_avatar(flash_name, name) {
    flashMovie(flash_name).buyAvatar(name);
}

function html_callback(flash_name, reload, drid) {
    flashMovie(flash_name).htmlCallback(reload, drid);
}

function flash_callback(e) {
    try {
        wizards.sendPipeMessage(Number(e.ref.height) + Number(document.body.offsetHeight));

    } catch(e) {
    }
}

function onLoading(url) {
    showLoader();
}

function onLoaded(url) {
    
    wizards.onCallback();
    if(Object.isString(url)) {
        _gaq.push(['_setAccount', 'UA-17359215-1']);
        _gaq.push(['_trackPageview', url]);
    }
}

function showLoader()
{
    try {
        $("background_loader").setStyle({
            display: "block"
        });

        $("loader_content").setStyle({
            margin: screen.height/3 + "px auto"
        });

        $("loader_overlay").setStyle({
            display: "block"
        });
    } catch(e) {

    }
}

function hideLoader() {
    setTimeout(function(){
        try {
            $("background_loader").setStyle({
                display: "none"
            });
            $("loader_overlay").setStyle({
                display: "none"
            });
        } catch(e) {

        }
    }, 100);
}

var wizardsScreen = {
    f_filterResults: function(n_win, n_docel, n_body) {
        var n_result = n_win ? n_win : 0;
        if (n_docel && (!n_result || (n_result > n_docel)))
            n_result = n_docel;
        return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
    },

    f_clientWidth: function() {
        return this.f_filterResults (
            window.innerWidth ? window.innerWidth : 0,
            document.documentElement ? document.documentElement.clientWidth : 0,
            document.body ? document.body.clientWidth : 0
            );
    },

    f_clientHeight: function() {
        return this.f_filterResults (
            window.innerHeight ? window.innerHeight : 0,
            document.documentElement ? document.documentElement.clientHeight : 0,
            document.body ? document.body.clientHeight : 0
            );
    },
    
    f_scrollLeft: function() {
        return this.f_filterResults (
            window.pageXOffset ? window.pageXOffset : 0,
            document.documentElement ? document.documentElement.scrollLeft : 0,
            document.body ? document.body.scrollLeft : 0
            );
    },
    
    f_scrollTop: function() {
        return this.f_filterResults (
            window.pageYOffset ? window.pageYOffset : 0,
            document.documentElement ? document.documentElement.scrollTop : 0,
            document.body ? document.body.scrollTop : 0
            );
    },

    findPosition: function(obj) {
        var curleft = 0;
        var curtop = 0;
        
        if (obj.offsetParent) {
            do {
                curleft += obj.offsetLeft;
                curtop += obj.offsetTop;
            } while (obj = obj.offsetParent);

        }
        return [curleft, curtop];
    }
}

var wizards = {
    user_id:null,
    partner_url:null,

    login: {
        remember_click: function() {
            var remember_link = $("check_box_link");
            var remember_me   = $("remember_me");
            remember_link.toggleClassName("checked");
            remember_me.checked = remember_link.hasClassName("checked");
        }
    },

    init: function(options) {
        ajax_mode        = options["ajax_mode"];
        this.partner_url = options["partner_url"];
        this.user_id     = options["user_id"];

        this.sendPipeMessage();
        
        this.onCallback();
    },

    onCallback: function() {
        //  $$('a').lock("active_always");
        //  $$('form').lock("active_always");
        window.setTimeout(function() {
            //            Locker.clearLockStatus();
            hideLoader();
        }, 10);
        
        wizards.controls.init();
        
    },

    addThisInit: function() {
        //AddThis reset
        if (window.addthis) {
            var scripts = document.getElementsByTagName("script");
            for(var i = 0; i < scripts.length; i++) {
                var s = scripts[i];
                if(s && s.src == urlHelper.getAddThisUrl())
                {
                    Element.remove(s);
                }
            }
            window.addthis = null;
        }
        loadjs(urlHelper.getAddThisUrl());
    },

    //scroll to top on error
    onNoticeScroll: function() {
        $('notification').scrollTo();
    },

    onScrollTop: function() {
        $('user_info').scrollTo();
    },

    navigateToProfile: function(id) {
        navigate(urlHelper.profileUrl() + "/" + id);
    },

    createCookie:function(name, value, days, secure) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
        document.cookie = name+"="+value+expires+"; path=/; "+((secure) ? "; secure" : "")+"host="+document.location.host;
    },

    readCookie:function(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];

            while (c.charAt(0)==' ') {
                c = c.substring(1,c.length);
            }

            if (c.indexOf(nameEQ) == 0) {
                return c.substring(nameEQ.length,c.length);
            }
        }

        return null;
    },

    deleteCookie: function(name) {
        if(readCookie(name)) {
            createCookie(name, "", 0);
        }
    },

    fixIeUnload: function() {
        // Is there things still loading, then fake the unload event
        if (document.readyState == 'interactive') {
            function stop() {
                // Prevent memory leak
                document.detachEvent('onstop', stop);

                // Call unload handler
                wizards.unload();
            };

            // Fire unload when the currently loading page is stopped
            document.attachEvent('onstop', stop);

            // Remove onstop listener after a while to prevent the unload function
            // to execute if the user presses cancel in an onbeforeunload
            // confirm dialog and then presses the stop button in the browser
            window.setTimeout(function() {
                document.detachEvent('onstop', stop);
            }, 0);
        }
    },

    isChatDefined: function() {
        return (typeof(chat) == "undefined") ? false : true
    },

    unload: function() {
        if(wizards.isChatDefined()) {
    // chat.resetIeConnection();
    }
    },

    imposeMaxLength: function (evt, Object, MaxLen) {
        var charCode = (evt.which) ? evt.which : evt.keyCode
        if (charCode == 46 || charCode == 8||charCode==37||charCode==39) return true;
        return (Object.value.length <= MaxLen);
    },

    tracking: {

        track: function() {
            
            var search = location.search.replace(/^\?{1}/, '').split('&');

            for (var i=0; i<search.length; i++) {
                var kv = search[i].split('=');
                var key = kv[0];
                var value = kv[1];
                if ( key == 'rf' ) {
                    key = 'kw'
                }
                
                if ( key == 'src' || key == 'cid' || key == 'kw' || key == 'partner' ) {
                    wizards.createCookie('7wz_'+key, value, 30);
                }
            }
            if ( document.referrer !== undefined && document.referrer != "" &&(-1 == document.referrer.search(/^http(s?):\/\/www\.7wizards\.com\//i) ) ) {
                wizards.createCookie('7wz_rfv', document.referrer, 30);
            }
        }

    },

    is_on_frame: function () {
        return top.location != location;
    },

    show_new_messages: function(new_messages) {
        var message = $('go_new_mail');

        if(!message) return;

        if(new_messages) {
            message.show();
        } else {
            message.hide();
        }
    },
    
    currentHeight:600,

    sendPipeMessage: function(height) {

            
        var search = location.search.replace(/^\?{1}/, '').split('&');
        var params = {};
        for (var i=0; i<search.length; i++) {
            var kv = search[i].split('=');
            params[kv[0]]=kv[1];
        }
            
        if(height) {
            wizards.currentHeight = height;
        } else {
            wizards.currentHeight = document.body.offsetHeight
        }

        var par = ""//fir restore password
        if(params['rh'] !== undefined) {
            par = "?rh="+params['rh'];
        }
            
        if(this.partner_url && this.is_on_frame()) {
            parent.location = this.partner_url + par + "#" + wizards.currentHeight;
        }
        
        wizards.hi5height(wizards.currentHeight);

    },

    hi5height: function(heigth) {
        if(typeof(hi5) != "undefined") {
            hi5.Api.setCanvasHeight(heigth, function() {});
        }
    },

    is_render_done: function() {
        
        var iframe = document.getElementById("yui-history-iframe");
        var rendered = false;
        try {
            if(iframe.contentWindow.okToResumeParent){
                rendered = true;
            }
        } catch(e) {
            clearInterval(intervals["timer"]);
        //window.location = urlHelper.logout();
        }
        return rendered;
    },

    controls: {
        init: function() {
            //TODO
            //this.initTips();
            
            this.initSelect();
            this.initInputs();

        },

        initTips: function() {
            //TODO IS NOT COMPLEATED
            
            var li_img = $$("ul.information_tips_block li.image_block");
            var maxWidth = wizardsScreen.f_clientWidth();
            for(var a = 0; a < li_img.length; a++) {
                var image  = li_img[a].getElementsByTagName('img')[0];
                var li_tip = li_img[a].siblings()[0];
                li_tip.style.top  = image.getHeight() + "px";

                var size = wizardsScreen.findPosition(image)
                if(size[0] + li_tip.getWidth() > maxWidth) {
                    li_tip.style.left = maxWidth - (size[0] + li_tip.getWidth());
                } else {
                    li_tip.style.left = image.offsetLeft + "px";
                }
            }

        },

        initSelect: function() {
            var textnode, option, active, span = Array();
            var inputs = document.getElementsByTagName("select");
            for(var a = 0; a < inputs.length; a++) {
                if(inputs[a].className == "styled") {
                    option = inputs[a].getElementsByTagName("option");
                    active = option[0].childNodes[0].nodeValue;
                    textnode = document.createTextNode(active);
                    for(var b = 0; b < option.length; b++) {
                        if(option[b].selected == true) {
                            textnode = document.createTextNode(option[b].childNodes[0].nodeValue);
                        }
                    }
                    var id = "select" + inputs[a].name;
                    var el = $(id);
                    if (!Object.isElement(el)) {
                        span[a] = document.createElement("span");
                        span[a].className = "select";
                        span[a].id = id;
                        span[a].appendChild(textnode);
                        inputs[a].parentNode.insertBefore(span[a], inputs[a]);
                    }

                    if(!inputs[a].getAttribute("disabled")) {
                        inputs[a].onchange = wizards.controls.choose;
                    } else {
                        inputs[a].previousSibling.className = inputs[a].previousSibling.className += " disabled";
                    }
                }
            }
        },

        choose: function() {
            var option = this.getElementsByTagName("option");
            for(var d = 0; d < option.length; d++) {
                if(option[d].selected == true) {
                    document.getElementById("select" + this.name).childNodes[0].nodeValue = option[d].childNodes[0].nodeValue;
                }
            }
        },
        
        //Inputs controls
        initInputs: function() {
            $A(document.getElementsByTagName("input")).map(Element.extend).each(function(input) {
                if(input.hasClassName("styled")) {
                    var close_link = input.nextSibling;
                    if(Object.isElement(close_link) && close_link.tagName.toLowerCase() == "a") {

                        input.stopObserving("keyup");

                        input.observe("keyup", function(link, event) {
                            if(Event.element(event).value.length > 0) {
                                link.show();
                            } else {
                                link.hide();
                            }
                        }.bind(this, close_link));

                        Element.stopObserving(close_link, "click");

                        close_link.observe("click", function(input, self){
                            input.value = '';
                            self.hide();
                        }.bind(this, input, close_link));

                        if( document.createEvent ) {
                            var e = document.createEvent('HTMLEvents');
                            e.initEvent('keyup', true, true);
                            input.dispatchEvent(e);
                        } else {
                            input.fireEvent('onkeyup');
                        }
                    }
                }
            })

        }

    }

}

if(Prototype.Browser.IE)
{
    window.attachEvent('onunload', wizards.unload);
    window.attachEvent('onbeforeunload', wizards.fixIeUnload);
}

var clan = {
    changeFrontLogo: function(avaId, fieldId, imgId, url) {
        var res = $(fieldId).value.split(";");
        if(res.length < 2) {
            res = [];
            res[1] = "";
        }
        res[0] = avaId;
        clan.setClanLogo($(fieldId), res, $(imgId), url)
    },

    changeBackLogo: function(avaId, fieldId, imgId, url) {
        var res = $(fieldId).value.split(";");
        if(res.length < 2) {
            res = []
            res[0] = ""
        }
        res[1] = avaId
        clan.setClanLogo($(fieldId), res, $(imgId), url);
    },

    setClanLogo: function(field, fData, img, imgUrl)
    {
        field.value = fData[0] + ";" + fData[1];
        img.src = imgUrl;
    }
}

YAHOO.util.History.setFrameMode(wizards.is_on_frame());

var doNavigate = true;
var doHistory = false;
var bookmarkedSection = YAHOO.util.History.getBookmarkedState("nav");
var querySection =  YAHOO.util.History.getQueryStringParameter("section");
var initialSection = bookmarkedSection || querySection || ""//urlHelper.homeUrl();
var already_navigated = false; //

function addHistory(url) {
    //console.log("ADD_HISORY: " + url);
    try {
        if(doHistory) {
            doHistory = false;
            return;
        }
        
        doNavigate = false;
        if(ajax_mode) {

            //register ajax history
            YAHOO.util.History.navigate("nav", url);
            already_navigated = false;

            wizards.sendPipeMessage(); //send height for parrent windows
        }
    } catch(e) {
        //when library is not initialized
        already_navigated = true;
    }

}
if(location.href.indexOf("#") >= 0) {
    window.location = urlHelper.baseUrl() + initialSection;
}
    
//Initialize Ajax history
Event.observe(window, 'load', function() {
   
    if(ajax_mode) {

        YAHOO.util.History.register("nav", initialSection, function (state) {
            //console.log("REGISTER: " + state + "doNavigate = " + doNavigate);
            if(doNavigate && ajax_mode)
            {
                doHistory = true;
                //console.log("REGISTER NAVIGATE: " + state);
                navigate(state);
            }
            doNavigate = true;
        });


        intervals["timer"] = setInterval(function() {
            
            try {

                if(wizards.is_render_done()) {

                    clearInterval(intervals["timer"]);

                    YAHOO.util.History.initialize("yui-history-field", document.getElementById("yui-history-iframe"));

                    if(wizards.is_on_frame()) {
                        return;
                    }
                    
                    var hash = YAHOO.util.History.getCurrentState("nav");
                    // console.log("INITIALIZE: " + hash);
                    if(Object.isNumber(wizards.user_id) && ajax_mode && !already_navigated) {
                        
                //navigate(hash);
                }
                }
            } catch(e) {
                clearInterval(intervals["timer"]);
                throw Error(e)
            }
        }, 100);
        
        
        
    }
})

var dialog = {

    content:null,
    is_over:true,
    background:null,

    init_close: function(config) {
        dialog.content           = config.preview_dialog;

        Event.observe(dialog.content, "mouseover", dialog.onOver.bind(this));
        Event.observe(dialog.content, "mouseout",  dialog.onOut.bind(this));
        Event.observe(window, "click", dialog.onGlobalClick.bind(this));
    },
    
    close: function() {
        if(dialog.background) {
            dialog.background.remove();
            dialog.background = null;
        }

        $('dialog_content').hide();
        $('dialog_content').innerHTML = "";
    },

    show: function(){

        if(dialog.background == null) {
            var h = wizardsScreen.f_clientHeight() + wizardsScreen.f_scrollTop() + "px";
            dialog.background = new Element("div", {
                "id":"popup_background_layer",
                "style":"z-index: 10; opacity:0.3; filter:alpha(opacity=40); background-color: black; display: block; position:fixed; height:"+h+"; width:100%"
            });

            $$("body")[0].insert({
                "top":dialog.background
            });
            
        }
        
        dialog.content = $('dialog_content');
        dialog.content.addClassName("invisible");
        
        dialog.content.show();
        
        dialog.setPosition();

        dialog.content.removeClassName("invisible")
    },



    onOver: function(event) {
        dialog.is_over = true;
    },

    onOut: function(event) {
        dialog.is_over = false;
    },

    onGlobalClick: function(event) {
        if(!dialog.is_over) {
            dialog.close();
        }
    },

    setPosition: function() {
        dialog.content = $('dialog_content');
        var child   = dialog.content.firstDescendant()
        var cHeight = (wizardsScreen.f_clientHeight() - child.getHeight())/2;

        if(location.toString().match(/hi5.7wizards/) != null) {
            cHeight = currentMouseY - child.getHeight()/2;
            if(cHeight < 1) {
                cHeight = 100;
            }
        }

        child.style.marginTop = cHeight + wizardsScreen.f_scrollTop() + "px";
        child.style.marginLeft =(wizardsScreen.f_clientWidth() - child.getWidth())/2 + wizardsScreen.f_scrollLeft() + "px";

    }
}


var SelectAutoCompleate = Class.create({
    initialize: function(o) {
        this.max_size = o.size || 10;
        this.min_size = 4;
        this.input_hover = false;
        
        this.input = $(o.input_id);
        this.input.setAttribute("autocomplete", "off");
        
        this.select = $(o.select_id);
        
        this.options = $$('select#'+o.select_id+' option');
        this.values = Array();
        this.texts  = Array();
        this.length = 0;
        this.populateOptions();

        Event.observe(this.input, "click", this.onClick.bind(this));
        Event.observe(this.input, "mouseover", this.onOver.bind(this));
        Event.observe(this.input, "mouseout", this.onOut.bind(this));
        Event.observe(this.input, "keyup", this.keyUp.bind(this));
        Event.observe(this.select,"click", this.selectClick.bind(this));
        Event.observe(this.select,"keydown", this.selectKeyDown.bind(this));
        Event.observe(window, "click", this.onGlobalClick.bind(this));
    },

    onOver: function(e) {
        this.input_hover = true;
    },

    onOut: function(e) {
        this.input_hover = false;
    },

    onGlobalClick: function(event) {
        if(!this.input_hover) {
            this.select.hide();
        }
    },

    onSelect: function(option){
    //Should override
    },

    populateOptions: function() {
        this.length = this.options.length;
        for (var i = 0; i < this.length; i++) {
            this.values.push(this.options[i].value);
            this.texts.push(this.options[i].text);
        }
    },

    keyUp: function(e) {
        //press down button
        if(e && (e.keyCode == 40 || e.keyCode == 38)) {
            this.select.focus();

            if(this.select.options.length > 0)
                this.select.options[0].setAttribute("selected", "selected");
            
            return;
        }
        
        var reg = new RegExp("^"+this.input.value,"gi");
        var index = 0;
        var count = 0;

        this.select.innerHTML = '';
        
        for(var i = 0; i < this.length; i++)
        {
            if(this.texts[i].search(reg) != -1) {
                var opt = new Element('option', {
                    value:this.values[i]
                });
                opt.innerHTML = this.texts[i];
                this.select.insert({
                    bottom:opt
                })
                count++;
            } 
            index++;
        }

        if(count > this.max_size) {
            this.select.setAttribute("size", this.max_size);
        } else if(count < this.min_size) {
            this.select.setAttribute("size", this.min_size);
        } else {
            this.select.setAttribute("size", count);
        }

        if(count == 0) {
            this.select.hide();
        } else {
            this.select.show();
        }
    },

    onClick: function() {
        this.select.show();
        this.keyUp();
    },

    selectClick: function() {
        this.input.value = this.select.options[this.select.selectedIndex].text;
        this.onSelect(this.select.options[this.select.selectedIndex]);
        this.select.hide();
    },

    selectKeyDown: function(e) {
        if(e && (e.keyCode == 8)) {
            this.input.focus();
        }

        //press enter
        if(e && (e.keyCode == 13)) {
            this.selectClick();
        }
    }
});

var InputHolder = Class.create({
    initialize: function(id, text) {
        this.element = $(id);
        this.text = text;
        this.default_style = {
            color: "#8B48B9"
        };
        this.holder_style = {
            color: "#CCCCCC",
            fontSize: "13px",
            fontWeight:"normal"
        };

        this.type = this.element.getAttribute("type").toLowerCase();
        
        this.is_empty = false;
        this.element.setStyle(this.default_style);

        this._validate();

        Event.observe(this.element,"focus", this.onFocus.bind(this));
        Event.observe(this.element,"blur", this.onUnFocus.bind(this));
    },

    onFocus: function() {
        if(this.is_empty) {
            this.element.setStyle(this.default_style);
            this.element.value = "";
            
            if(this.type == "password") this.element.setAttribute("type", this.type);
        }
    },

    onUnFocus: function() {
        this._validate();
    },
    
    _validate: function() {
        if(Object.isElement(this.element) && (this.element.value.length == 0||this.element.value==this.text)) {

            if(this.type == "password") this.element.setAttribute("type", "text");

            this.element.value = this.text;
            this.element.setStyle(this.holder_style);
            this.is_empty = true;
        } else {
            this.is_empty = false;
            this.element.setStyle(this.default_style);
        }
    },

    clear: function() {
        if(Object.isElement(this.element) && (this.element.value==this.text)) {
            this.element.value = "";
        }
    }

})

//SCROLLER
var visitor = {
    is_over: false,
    scroll_step:778,
    scrolled_content:null,
    dialog:null,
    items_count:7,
    max_width:5446,
    init: function(config) {
        visitor.scrolled_content = config.inner_scroll;
        visitor.dialog           = config.preview_dialog;

        $$("div#preview_dialog div#inner_scoll img").each(function(img){
            img.observe("click", function(){
                visitor.scroll_right()
            });
        });

        dialog.init_close({
            preview_dialog: config.preview_dialog
        });
    },
    scroll_left: function() {
        var margin = visitor.scrolled_content.style.marginLeft;
        margin = Number(margin.replaceAll("px", "")) + visitor.scroll_step;
        if(margin > 0) {
            margin = visitor._get_limit();
        }
        visitor.scrolled_content.style.marginLeft = String(margin) + "px";
    },
        
    scroll_right: function() {

        var margin = visitor.scrolled_content.style.marginLeft;
        margin = Number(margin.replaceAll("px", "")) - visitor.scroll_step;

        if(margin < visitor._get_limit()) {
            margin = 0;
        }
        visitor.scrolled_content.style.marginLeft = String(margin) + "px";
    },

    _get_limit: function(){
        return -visitor.scroll_step*(visitor.items_count - 1);
    }
        
}

var WizardsClock = Class.create({
    element:null,

    currentYear:0,
    currentMonth:0,
    currentDays:0,
    currentHours:0,
    currentMinutes:0,
    currentSeconds:0,

    interval:null,
    current_time:null,
    monthes:["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    date_time:null,
    initialize: function(element, time) {
        this.element = $(element);

        this.current_time = time;

        if(this.interval) {
            clearInterval(this.interval);
        }

        this.interval = window.setInterval(function(){
            this.adjust();
        }.bind(this), 1000);
    },

    adjust: function() {

        if(!this.date_time) {
            this.date_time = new Date(this.current_time);
        }
        this.current_time += 1000;
        this.date_time.setTime(this.current_time);

        this.currentYear    = this.date_time.getUTCFullYear();
        this.currentMonth   = this.date_time.getUTCMonth();
        this.currentDays    = this.date_time.getUTCDate();
        this.currentHours   = this.date_time.getUTCHours();
        this.currentMinutes = this.date_time.getUTCMinutes();
        this.currentSeconds = this.date_time.getUTCSeconds();
        
        this.element.innerHTML = 
        this.format(this.currentDays) + " " +
        this.monthString(this.currentMonth) + " " +
        this.format(this.currentHours) + ":" +
        this.format(this.currentMinutes) + ":" +
        this.format(this.currentSeconds);

    },

    format: function(value) {
        return ( value < 10 ? "0" : "" ) + value;
    },

    monthString: function(month) {
        return this.monthes[month];
    },

    toElement: function() {
        return this.element;
    }
    
})


function init_facebook(app_id, callback) {
    (function() {
        var e = document.createElement('script');
        e.type = 'text/javascript';
        e.src = document.location.protocol +
        '//connect.facebook.net/en_US/all.js';
        e.async = true;
        document.getElementById('fb-root').appendChild(e);
    }());

    window.fbAsyncInit = function() {
        FB.init({
            appId: app_id,
            status: true,
            cookie: true,
            xfbml: true
        });
        callback.call(this);
    }.bind(this);
}





