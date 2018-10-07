var chat = {

    interval:{},
    expanded:false,
    ape:null,
    views:{},
    
    chat_options: {
        chat_enabled:true,
        server_host:null,
        server_port:80,
        smiles:null,
        nav_container:null,
        msg_container:null,
        user_container:null,
        smile_container:null,
        rooms_container:null,
        avatar_container:null,
        error_container:null,
        amazone_avatar_url:null
        
    },

    user_options: {
        user_id:0,
        user_name:"",
        user_level:0,
        clan_id:null,
        gender:"m",
        avatar:null,
        is_moderator:false,
        confirmed_email:false,
        blocked:false,
        blocked_reason:"",
        session_id:null
    },
    
    initialize: function(debug, chat_options, user_options) {

        chat.chat_options = chat_options;
        chat.user_options = user_options;

        chat.chat_options.filter = $('filter');

        chat.views.collapsed_panel = $("collapsed_chat_mode");
        chat.views.expanded_panel  = $("expanded_chat_mode");
        
        chat.views.users_inner     = $("inner_scrolled_content");
        chat.views.user_avatar     = $("chat_user_avatar");         // selected avatar

        if(!chat.chat_options.chat_enabled) {
            return;
        }

        var port = chat.chat_options.server_port.toString().blank() ? "" : ":" + chat.chat_options.server_port;
        
        APE.Config.baseUrl = "http://" + chat.chat_options.server_host + port + "/javascripts/ape-jsf"; //APE JSF
        APE.Config.domain  = 'auto';
        APE.Config.server  = chat.chat_options.server_host + ':6969'; //APE server URL
        APE.Config.isDebug = debug;

        (function(){
            for (var i = 0; i < arguments.length; i++)
                APE.Config.scripts.push(APE.Config.baseUrl + '/Source/' + arguments[i] + '.js');
        })('mootools-core', 'Core/APE', 'Core/Events', 'Core/Core', 'Pipe/Pipe', 'Pipe/PipeProxy', 'Pipe/PipeMulti', 'Pipe/PipeSingle', 'Request/Request','Request/Request.Stack', 'Request/Request.CycledStack', 'Transport/Transport.longPolling','Transport/Transport.SSE', 'Transport/Transport.XHRStreaming', 'Transport/Transport.JSONP', 'Core/Utility', 'Core/JSON', 'Core/Session');

        chat.interval["show_chat"] = setInterval(function() {
            chat.show_content();
        }, 50);
        
    },

    connectApe: function() {

        if(chat.ape == null) {
            // Initialize APE_Client
            chat.ape = new APE.Chat(chat.chat_options, chat.user_options);

            //Addition validation should be in server side
            //TODO
            if(Number(chat.user_options.user_level) < 3) {
                chat.ape.show_warning("Required level 3", false);
                //                setTimeout(function(){
                //                    chat.ape._get_users("replace", "", "");
                //                }, 2000);
                return;
            } 

            // Connect to the APE Server
            chat.ape.load({
                identifier: 'wizards', // Identifier of the application
                channel: 'public' // Channel to join at startup
            });

        }

        chat.ape.scrollMsg();
    },

    onCallbackUsers: function(data) {
        chat.ape.userData(data);
        chat.ape.scroll_reset();
    },

    onCallbackHistory: function(data) {
        chat.ape.msgData(data);
    },

    show_content: function() {
        if(wizards.is_render_done()) {
            clearInterval(chat.interval["show_chat"]);
            Effect.SlideDown('chat_content_slide');

            for(var p in chat.chat_options) {
                try {
                    if(Object.isElement(eval(chat.chat_options[p]))) {
                        chat.chat_options[p] = eval(chat.chat_options[p]);
                    }
                    
                } catch(e) {
                }
            }

            if(!chat.ape) {
                //FOR TEST ONLY
                //move it to expand method
                setTimeout(function(){
                    chat.connectApe();
                }, 100);
            } 
            
        }
    },

    expand: function() {
        
        if(Number(chat.user_options.user_level) < 3) {
            new Ajax.Request('/chat/warning',
            {
                asynchronous:true,
                evalScripts:true,
                onLoaded:function(request){
                    javascript: onLoaded('/chat/warning')
                    },
                onLoading:function(request){
                    javascript: onLoading('/chat/warning');
                }
            });
            return;
        }

        chat.expanded = true;
        chat.views.collapsed_panel.hide();
        chat.views.expanded_panel.show();

        if(chat.ape) {
            chat.ape.scrollMsg();
        }

        wizards.hi5height(wizards.currentHeight + 300);
    },
    
    collapse: function() {
        chat.expanded = false;
        chat.views.collapsed_panel.show();
        chat.views.expanded_panel.hide();
        
        wizards.hi5height(wizards.currentHeight);

    },

    //scroller for users list
    scroll_left: function() {
        chat.ape.scroll_left();
    },

    //scroller for users list
    scroll_right: function() {
        chat.ape.scroll_right();
    },

    changeAutoscroll: function() {
        chat.ape.changeAutoscroll();
        chat.ape.scrollMsg();
    },

    cleanView:function() {
        chat.ape.clear();
    },

    addSmile: function(smile) {
        chat.ape.add_smile(smile);
    },

    addErrorMessage: function(message) {
        chat.ape.show_warning(message, true);
    }

}
