APE.Chat = Class.create();
APE.Chat.prototype = Object.extend(new APE.Client(), {

    chat_options:{
        nav_container: null,
        msg_container: null,
        user_container: null,
        smile_container: null,
        rooms_container:null,
        avatar_container:null,
        smiles:null,
        filter:null,
        error_container:null,
        amazone_avatar_url:null
        
    },

    user_options:{
        user_id:null,
        user_name:null,
        user_level:0,
        clan_id:null,
        gender:"m",
        avatar:null,
        is_moderator:false,
        confirmed_email:false,
        blocked:false,
        blocked_reason:"",
        session_id:0
    },

    user_scroll:{
        step:116,           //user image width
        max_width:812,      //user panel max width
        per_screen_count:7, //users per page
        items_count:10      //users count in panel
    },

    users_panel:{},
    user_avatar:{},

    autoscroll:true,
    publicPipe:null,
    locked:false,

    say_text:"",
    say_to_name:"",

    timer:null, //time hint

    initialize: function(chat_options, user_options){
        this.els = {};

        this.chat_options = chat_options;
        this.user_options = user_options;
        
        this.chat_options.def_room = "public";
        this.chat_options.online_tag = $$("span.chat_activity");

        this.currentPipe = null;

        this.logging = true;

        this.onRaw('data', this.rawData);
        this.onRaw('info', this.forceLeave);
        this.onRaw('ban',  this.ban);
        
        this.onCmd('send', this.cmdSend);

        this.onError('004', this.reset);
        this.onError('006', this.promptName);
        this.onError('007', this.promptName);
        //this.onError('050', this.promptName);

        this.addEvent('load', this.start);
        this.addEvent('ready', this.createChat);
        this.addEvent('uniPipeCreate', this.setPipeName);
        this.addEvent('uniPipeCreate', this.createPipe);
        this.addEvent('multiPipeCreate', this.createPipe);
        this.addEvent('userJoin', this.createUser);
        this.addEvent('userLeft', this.deleteUser);

        this._init_filter();
    },

    promptName: function(errorRaw){
        this.els.namePrompt = {};

        //        this.options.name =  this.user_options.user_name;
        this.start();

        var error;
        if (errorRaw) {
            if (errorRaw.data.code == 007) error = 'This nick is already in use';
            if (errorRaw.data.code == 006) error = 'Bad nick, a nick must contain a-z 0-9 characters';
            if (errorRaw.data.code == 050) error = 'You need to reach level 3 to chat';
            if (error) {

                this.show_warning(error, false);
                this.core.clearSession();
                
            //console.log(errorRaw.data.code)

            }
        }
    },

    start: function() {
        //If name is not set & it's not a session restore ask user for his nickname
        if(!this.user_options.user_name && !this.core.options.restore){
            this.promptName();
        } else{
            var opt = {
                'sendStack': false,
                'request': 'stack'
            };

            this.core.start({
                "id":this.user_options.user_id,
                'name':this.user_options.user_name,
                "gender":this.user_options.gender,
                "avatar":this.user_options.avatar,
                "level" :this.user_options.user_level,
                "blocked":this.user_options.blocked,
                "session":this.user_options.session_id
            }, opt);

            
            //seems not need
            //            if (this.core.options.restore) {
            //                this.core.getSession('currentPipe', function(resp) {
            //                    console.log("restore")
            //                    this.setCurrentPipe(resp.data.sessions.currentPipe);
            //                }.bind(this), opt);
            //            }

            this.core.request.stack.send();

        }
    },

    setPipeName: function(pipe, options) {
        if (options.name) {
            pipe.name = options.name;
            return;
        }
        if (options.from) {
            pipe.name = options.from.properties.name;
        } else {
            pipe.name = options.pipe.properties.name;
        }
    },

    getCurrentPipe: function(){
        //        if(this.currentPipe == null && this.publicPipe != null) {
        //            this.currentPipe = this.publicPipe;
        //        }
        return this.currentPipe;
    },

    setCurrentPipe: function(pubid, save){
        //TODO ERROR FOR OFFLINE USERS
        //        if(this.currentPipe.els == null) {
        //            this.writeMessage(this.getCurrentPipe(), data.msg, this.core.user);
        //        }
        save = !save;

        if (this.getCurrentPipe()) {
            //not work for IE7
            //            this.currentPipe.els.messages.setAttribute("style", "display:none");
            this.currentPipe.els.messages.hide();

            this.currentPipe.els.room_link.removeClassName("selected");
        }

        this.currentPipe = this.core.getPipe(pubid);
        
        //        if(this.currentPipe) {

        //not work for IE7
       
        //        this.currentPipe.els.messages.setAttribute("style", "display:block");
        this.currentPipe.els.messages.show();
        this.currentPipe.els.room_link.addClassName("selected");
        this.els.group_rooms.new_message[this.currentPipe.getPubid()].innerHTML = "";

        this.scrollMsg();
        if (save) this.core.setSession({
            'currentPipe':this.getCurrentPipe().getPubid()
        });
        //        }
        
        return this.currentPipe;
    },

    cmdSend: function(data, pipe){
        this.core.user.properties["online"] = true;
        this.writeMessage(pipe, data.msg, this.core.user, new Date().getTime());
        this.els.sendbox.focus();
    },

    rawData: function(raw, pipe) {
        raw.data.from.properties["online"] = true;
        raw.data.from.properties["pubid"]  = raw.data.from.pubid;
        if(raw.data.from.properties["blocked"] == 0) {
            this.writeMessage(pipe, raw.data.msg, raw.data.from, raw.time*1000);
        } 
    },

    parseMessage: function(message){
        return decodeURIComponent(message);
    },

    notify: function(pipe){
        this.els.group_rooms.new_message[pipe.getPubid()].update(new Element("img", {
            "src":"/images/design/chat_mail_sign.gif"
        }))
    },

    scrollMsg: function(){
        try {
            if(this.autoscroll) {
                this.chat_options.msg_container.scrollTop = this.chat_options.msg_container.scrollHeight + 10;
            }
            
        } catch(e) {
        }
    },

    writeMessage: function(pipe, message, from, time, from_history){
        
        //Append message to last message
        if( pipe && typeof(Array().lastMsg) != 'undefined' &&  pipe.lastMsg && pipe.lastMsg.from.pubid == from.pubid){
            var cnt = pipe.lastMsg.el;
        }else{//Create new one

            var li = new Element("li");
            var info_link = new Element("a", {
                "href":"javascript: void(0)" //javascript: chat.navigateToProfile(34)
            });

            info_link.insert({
                "bottom": new Element("img", {
                    "src":"/images/design/info_alb.png"
                })
            });

            info_link.observe("click", function(u) {
                this.showAvatar(u);
            }.bind(this, from.properties));

            var user = this.user_options.user_name;

            if (from && from.properties) {
                user = from.properties.name
            }
            var say_to = new Element("a", {
                "href":"javascript: void(0)",
                "onclick":"javascript: void(0)",
                "class":"active_always"
            }).insert(user);

            say_to.observe("click", function(name){
                this.say_to(name);
            }.bind(this, user))

            var msg = new Element("span").insert(": " + this.make_smiles(message.escapeHTML()))

            li.insert({
                "bottom":info_link
            });
            li.insert({
                "bottom":say_to
            });
            
            li.insert({
                "bottom":msg
            });

            //show hint with time
            li.observe('mouseover',function(time, ev) {
                //currentMouseX, currentMouseY from utils.js
                //this._createTimeHint(time/1000, currentMouseX, currentMouseY);
                if(!this.timer) {
                    this.timer = new TimeHint({
                        "class":"chat_hint_time"
                    });
                    $$('body')[0].insert(this.timer);
                    this.timer.hide();
                }

                this.timer.setTime(time);
                setTimeout(function(time){
                    if(this.timer) {
                        this.timer.show();
                        this.timer.setPosition(currentMouseX, currentMouseY);
                    }
                }.bind(this), 600, time);

            }.bind(this, time));

            //hide hint with time
            li.observe('mouseout',function(ev){
                if(this.timer) {
                    this.timer.remove();
                    delete(this.timer);
                }
            }.bind(this));

            pipe.els.messages.insert({
                "bottom":li
            });

        }

        pipe.lastMsg = {
            from:from,
            el:cnt
        };
        
        this.scrollMsg();

        //notify
        if(this.getCurrentPipe() && this.getCurrentPipe().getPubid()!=pipe.getPubid() && !from_history){
            this.notify(pipe);
        }
    },

    createUser: function(user, pipe) {
        this.createAvatar({
            id:user.properties.id,
            name:user.properties.name,
            gender:user.properties.gender,
            avatar:user.properties.avatar,
            level:user.properties.level,
            online:true,
            pubid:user.pubid
        }, "top");

        //if user does not exists
        if(!this.online_users[user.properties.id]) {
            this.update_online(1);
        }
        this.online_users[user.properties.id] = user;
        
        //Join clan room
        if(this.user_options.clan_id && this.user_options.user_name == user.properties.name) {
            this.core.join("clan_" + this.user_options.clan_id);
        }

    },

    deleteUser: function(user, pipe){
        this.rem_private_room(user.pubid);
        if(this.users_panel[user.properties.id]) {
            this.users_panel[user.properties.id].user_ul.remove();
            delete(this.users_panel[user.properties.id]);
            delete(this.online_users[user.properties.id]);
        }

        this.update_online(-1);

    },

    leaveUser: function(pipe) {
        this.rem_private_room(pipe.getPubid());
        pipe.request.send('leaveuni', {
            "pipe":pipe
        });
        this.core.left(pipe.getPubid());
    },

    forceLeave: function(raw, pipe) {
        if(raw.data.action == "userLeave") {
            this.rem_private_room(pipe.getPubid())
            this.core.left(pipe.getPubid());
        }

    },

    ban: function(raw, pipe) {
        this.user_options.blocked = raw.data.blocked;
        this.user_options.blocked_reason = raw.data.reason;

    },

    createPipe: function(pipe, options) {
        pipe.els = {};

        pipe.els.messages = new Element("ul", {
            "class":"chat_message_content",
            "style":"display:none"
        });
        this.chat_options.msg_container.insert(pipe.els.messages);

        var room_name = pipe.name;
        if(room_name.match(/clan_/i)) {
            room_name = "Clan";
        } else if (room_name == this.chat_options.def_room) {
            room_name = "Public";
            this.publicPipe = pipe;
        }

        pipe.els.room_link = new Element("a", {
            "href":"javascript: void(0)"
        }).insert(room_name);
        
        pipe.els.room_link.observe("click", function(pipe, ev) {

            if(ev.target != this.getCurrentPipe().els.room_link) {
                this.setCurrentPipe(pipe.getPubid());
            }
            
        }.bind(this, pipe));
        
        //Link leave chat room
        var leave_link = new Element("a", {
            "href":"javascript: void(0)"
        });
        leave_link.insert(new Element("img", {
            "src":"/images/design/cross_chat_button.gif",
            "width":"11"
        }));
        leave_link.observe("click", function(pipe, ev){
            this.leaveUser(pipe);
        }.bind(this, pipe));

        var span_right = new Element("span", {
            "class":"right"
        });
        var span_new   = new Element("span", {
            "class":"chat_new_message"
        });
        span_right.insert({
            "bottom":span_new
        });

        //User can't leave public chat room
        if(pipe.type != "multi") {
            span_right.insert({
                "bottom":new Element("span", {
                    "class":"delete_chat"
                }).insert(leave_link)
            });
        }

        if(pipe.type == "multi") {
            this.add_public_room(pipe, new Element("li").insert(pipe.els.room_link).insert({
                "bottom":span_right
            }), span_new);
        } else {
            this.add_private_room(pipe, new Element("li").insert(pipe.els.room_link).insert({
                "bottom":span_right
            }), span_new);

        }

        //we will be able use this fuction when new version of APE SERVER
        //will be realised (bug  "Segmentation fault")
        //this.core.request.send('getHistory', {
        //    room: this._getRoomName(pipe),
        //    pubid:pipe.getPubid()
        //});

        this._get_history(this._getRoomName(pipe), pipe.getPubid());

        if(pipe.name == this.chat_options.def_room) {
            //Hide other pipe and show this one
            this.setCurrentPipe(pipe.getPubid());
            this.publicLink = pipe.els.room_link;
        }

    },

    add_private_room: function(pipe, el, new_message) {
        if(this.els.group_rooms.room_list[pipe.getPubid()]) {
            this.els.group_rooms.room_list[pipe.getPubid()].remove();
        }
        
        this.els.group_rooms.room_list[pipe.getPubid()] = el;
        this.els.group_rooms.new_message[pipe.getPubid()] = new_message;
        this.els.group_rooms.priv[1].insert(this.els.group_rooms.room_list[pipe.getPubid()]);
    },

    add_public_room: function(pipe, el, new_message) {
        if(this.els.group_rooms.room_list[pipe.name]) {
            this.els.group_rooms.room_list[pipe.name].remove();
        }

        this.els.group_rooms.room_list[pipe.name] = el;
        this.els.group_rooms.new_message[pipe.getPubid()] = new_message;
        this.els.group_rooms.pub[1].insert(this.els.group_rooms.room_list[pipe.name]);
    },

    rem_private_room:function(pubid) {

        //Need change pipe to public if user has active this pipe
        if(this.currentPipe.getPubid() == pubid) {
            this.setCurrentPipe(this.publicPipe.getPubid());
            
        }
        
        if(this.els.group_rooms.room_list[pubid]) {
            this.els.group_rooms.room_list[pubid].remove();
        }
        
    },

    createChat: function() {
        //if chat already created need clear it
        if(this.els && this.els["send_button"]) {
            this.els.sendbox.remove();
            this.els.send_button.remove();
            this.els.sendboxForm.remove();
            this.chat_options.nav_container.innerHTML = "";
            this.chat_options.rooms_container.innerHTML = "";
        }

        this.online_users = {}
        
        this.els.smilelink = new Element('a',{
            "class":"active_always",
            "href":"javascript: void(0)"
        });

        this.els.smilelink.observe("click", function(ev) {
            this.show_smiles();
        }.bind(this));

        this.els.smilelink.insert(new Element('img',{
            "src":"/images/design/smiles_chat_open.png"
        }))

        this.els.sendbox = new Element('input',{
            'id':'chat_input',
            'type':'text',
            "class":"text",
            "maxlength":"255",
            'autocomplete':'off',
            "onkeyup":"javascript: void(0)"//chat.saytext(this)
        }).observe("keyup",function(ev){
            this.say_text = this.els.sendbox.value.replace(this.say_to_name + ": ", '');
        }.bind(this));

        this.els.send_button = new Element('input',{
            'type':'submit',
            'id':'sendbox_button',
            "class":"small_submit",
            'value':'Send'
        });

        this.els.sendboxForm = new Element('form');
        this.els.sendboxForm.insert({
            "bottom":this.els.sendbox
        });
        this.els.sendboxForm.insert({
            "bottom":this.els.send_button
        });
        this.els.sendboxForm.insert({
            "bottom":this.els.smilelink
        });


        this.els.sendboxForm.observe("submit", function(ev) {
            ev.stop();
            var val = this.els.sendbox.value;
            if(val!=''){
                if(this.locked) {
                    this.getCurrentPipe().els.messages.insert({
                        "bottom":"<li><i>Please, not that fast ;)</i></li>"
                    });
                    this.scrollMsg();
                } else if(this.user_options.blocked) {
                    this.getCurrentPipe().els.messages.insert({
                        "bottom":"<li style='color:red'><strong>You are blocked, reason: " +this.user_options.blocked_reason + "</strong></li>"
                    });
                    this.scrollMsg();
                } else {
                    this.getCurrentPipe().send(val)
                    
                    this.locked = true;
                    setTimeout(function(){
                        this.locked = false;
                    }.bind(this), 1000);

                    setTimeout(function(){
                        this.data_save(val);
                    }.bind(this), 50);

                    this.els.sendbox.value = "";
                    this.say_text = "";
                }

            }
        }.bind(this));

        this.chat_options.nav_container.insert(this.els.sendboxForm);

        this.els.group_rooms = {
            "pub":{},
            "priv":{},
            "room_list":{},
            "new_message":{}
        };

        //Build group rooms
        var create_room_group = function(name) {
            var group  = {}
            group.div  = new Element("div");
            group.ul   = new Element("ul");
            group.h3   = new Element("h3");
            group.link = new Element("a", {
                "href":"javascript: void(0)"
            });
            group.img  = new Element("img", {
                "src":"/images/design/chat_room_open.png"
            });
            group.link.insert(group.img);

            group.link.observe("click", function(img, ul, ev) {
                
                if(ul.style.display == "none") {
                    img.src = "/images/design/chat_room_open.png";
                    ul.setAttribute("style", "display:block")
                } else {
                    img.src = "/images/design/chat_room_close.png";
                    ul.setAttribute("style", "display:none");
                //                    ul.hide();
                }
            }.bind(this, group.img, group.ul));

            group.link.insert(group.img);
            
            group.h3.insert(group.link);
            group.h3.insert({
                "bottom":name
            });

            group.div.insert({
                "bottom":group.h3
            });
            group.div.insert({
                "bottom":group.ul
            });
            
            return [group.div, group.ul];
        };

        this.els.group_rooms.pub = create_room_group.call(null, ["Public chat"]);
        this.chat_options.rooms_container.insert(this.els.group_rooms.pub[0]);

        this.els.group_rooms.priv = create_room_group.call(null, ["Private chat"]);
        this.chat_options.rooms_container.insert(this.els.group_rooms.priv[0]);

        this._get_users("update","", "");

        //show online counter
        $$("div.left_chat_header").each(function(el) {
            el.show();
        })

    },

    //callback data from server side
    msgData: function(result) {
        

        for(var i = result.data.history.length - 1; i >= 0; i--) {
            var from = {
                properties:{
                    id:result.data.history[i].chat.id,
                    name:result.data.history[i].chat.name,
                    gender:result.data.history[i].chat.gender,
                    avatar:result.data.history[i].chat.avatar,
                    level:result.data.history[i].chat.a_level,
                    online:false
                }
            };
            this.writeMessage(this.core.getPipe(result.data.pubid), result.data.history[i].chat.message, from, result.data.history[i].chat.time*1000, true);
        }
        this.els.sendbox.focus();
    },

    //callback data from server side
    userData: function(result) {
        if(result.data.action == "replace") {
            this.users_panel = {};
            this.chat_options.user_container.innerHTML = "";
        }

        //add offline users from server side
        for(var j = 0; j < result.data.list.length; j++) {
            //var online = mysqlTimeStampToDate(result.data.list[j].chat_activity_time).getTime() > (Number(result.time + "000") - 60 * 20 * 1000);

            this.createAvatar({
                id:result.data.list[j].user.id,
                name:result.data.list[j].user.name,
                gender:result.data.list[j].user.gender,
                avatar:result.data.list[j].user.avatar,
                level:result.data.list[j].user.a_level,
                online:false
            }, "bottom");
        }
        
        //update online users
        if(result.data.action == "replace") {
            for( var uid in this.online_users) {
                if(this.users_panel[uid] || $("chat_user_name").value.blank()) {
                    if(this.chat_options.filter.value == this.online_users[uid].properties.gender || this.chat_options.filter.value == "pb")
                    {
                        this.createAvatar({
                            id:uid,
                            name:this.online_users[uid].properties.name,
                            gender:this.online_users[uid].properties.gender,
                            avatar:this.online_users[uid].properties.avatar,
                            level:this.online_users[uid].properties.level,
                            pubid:this.online_users[uid].pubid,
                            online:true
                        }, "top");
                    }
                }
            }
        }
    },

    //create avatar for top users panel
    createAvatar: function(user, position) {
        if(this.users_panel[user.id] && typeof(this.users_panel[user.id].user_ul) != 'undefined') {
            this.users_panel[user.id].user_ul.remove();
        } else {
            this.users_panel[user.id] = {};
        }

        this.users_panel[user.id].src = this.get_image_url(user)
        
        if(user.online) {
            this.users_panel[user.id].online_img = new Element("img",{
                "src":"/images/design/online_chat_pointer.png"
            });
        } else {
            this.users_panel[user.id].online_img = new Element("img",{
                "src":"/images/design/offline_chat_pointer.png"
            });
        }
        this.users_panel[user.id].user_link = new Element("a", {
            "href":"javascript: void(0)",
            "class":"chat_user_info"
        });

        this.users_panel[user.id].user_link.observe("click", function(u){
            this.showAvatar(u);
        }.bind(this, user));

        this.users_panel[user.id].user_link.insert(new ImageAvatar({
            "src":this.users_panel[user.id].src,
            "style":"height:109px; width: 102px",
            "alt":user.name
        }, user.gender));

        this.users_panel[user.id].user_ul = new Element("ul", {
            "class":"chat_user_info"
        });

        this.users_panel[user.id].li_top = new Element("li").insert(this.users_panel[user.id].user_link);
        this.users_panel[user.id].li_btn = new Element("li", {
            "class":"chat_user_info_name"
        }).insert(this.users_panel[user.id].online_img).insert({
            "bottom":user.name 
        })

        this.users_panel[user.id].user_ul.insert({
            "bottom":this.users_panel[user.id].li_top
        });
        this.users_panel[user.id].user_ul.insert({
            "bottom":this.users_panel[user.id].li_btn
        });

        if(position == "top") {
            this.chat_options.user_container.insert({
                "top":this.users_panel[user.id].user_ul
            })
        } else {
            this.chat_options.user_container.insert({
                "bottom":this.users_panel[user.id].user_ul
            })
        }
    },
    
    //build and show panel with selected avatar
    showAvatar: function(user) {
        if(this.user_avatar["ul"] && this.user_avatar["ul"] != 'undefined') {
            this.user_avatar.ul.remove();
        }
        
        if(user.online) {
            this.user_avatar.online_img = new Element("img",{
                "src":"/images/design/online_chat_pointer.png"
            });
        } else {
            this.user_avatar.online_img = new Element("img",{
                "src":"/images/design/offline_chat_pointer.png"
            });
        }
        this.user_avatar.top_bar = new Element("li", {
            "class":"chat_user_info_bar"
        });
        this.user_avatar.mid_bar = new Element("li", {
            "class":"selected_avatar"
        });
        this.user_avatar.btn_bar = new Element("li", {
            "class":"selected_avatar_controls"
        });

        //----------------------------------------------------------
        this.user_avatar.top_bar.insert(new Element("span").insert(this.user_avatar.online_img).insert({
            "bottom":user.name + " (Level: " + user.level + ")"
        }));

        this.user_avatar.link_close = new Element("a", {
            "href":"javascript: void(0)",
            "style":"float: right;"
        }).insert(new Element("img", {
            "src":"/images/design/cross_chat_button.png"
        }));

        this.user_avatar.link_close.observe("click", function(ev) {
            this.user_avatar.ul.remove();
            this.user_avatar = {}
            this.chat_options.avatar_container.hide()
            //            this.chat_options.avatar_container.setAttribute("style", "display:none");
            $("chat_messages_content").style.width = Prototype.Browser.IE ? "635px" : "596px";
            this.els.sendbox.style.width = Prototype.Browser.IE ? "500px" : "485px";
        }.bind(this));

        this.user_avatar.top_bar.insert(new Element("span").insert(this.user_avatar.link_close));
        //------------------------------------------------------------
        this.user_avatar.link_avatar = new Element("a", {
            "href":"javascript: void(0)"
        }).insert(new ImageAvatar({
            "style":"height:200px; width:192px",
            "id":"selected_big_avatar",
            "src":this.get_image_url(user),
            "alt":user.name
        }, user.gender));

        this.user_avatar.link_avatar.observe("click", function(u){
            wizards.navigateToProfile(u.id);
        }.bind(this, user));

        this.user_avatar.mid_bar.insert(this.user_avatar.link_avatar)
        //------------------------------------------------------------------
        //

        this.user_avatar.div_function = new Element("div", {
            "id":"functions"
        });
        //User can't invite self, or if his offline
        if(this.user_options.user_id != user.id && user.pubid !== undefined && user.pubid != null) {

            //link invite to private room
            this.user_avatar.private_link = new Element("a", {
                "title":"Private chats",
                "href" : "javascript: void(0)"
            }).observe("click", function(u){
                
                this.core.getPipe(u.pubid);
                this.setCurrentPipe(u.pubid);
                this.user_avatar.private_img.setAttribute("src", "/images/design/chat_lock.png");
            }.bind(this, user));

            this.user_avatar.private_img = new Element("img", {
                "src":"/images/design/chat_unlock.png"
            });
            this.user_avatar.private_link.insert(this.user_avatar.private_img);
            this.user_avatar.btn_bar.insert(this.user_avatar.div_function.insert(this.user_avatar.private_link));
        }

        if(this.user_options.user_id != user.id && this.user_options.is_moderator) {

            this.user_avatar.ban_link = new Element("a", {
                "title":"Block user",
                "href" : "javascript: void(0)"
            }).observe("click", function(u){

                this._request("/chat/block/" + u.id, false)
                
            }.bind(this, user));

            this.user_avatar.ban_img = new Element("img", {
                "src":"/images/design/chat_block.png"
            });
            this.user_avatar.ban_link.insert(this.user_avatar.ban_img);
            //TODO
            this.user_avatar.btn_bar.insert(this.user_avatar.div_function.insert(this.user_avatar.ban_link));
        }
        
        //------------------------------------------------------------------
        this.user_avatar.ul = new Element("ul");
        this.user_avatar.ul.insert({
            "bottom":this.user_avatar.top_bar
        });
        this.user_avatar.ul.insert({
            "bottom":this.user_avatar.mid_bar
        });
        this.user_avatar.ul.insert({
            "bottom":this.user_avatar.btn_bar
        });

        this.chat_options.avatar_container.insert(this.user_avatar.ul);
        this.chat_options.avatar_container.setAttribute("style", "display:block");
        this.chat_options.avatar_container.show();
        
        $("chat_messages_content").style.width = Prototype.Browser.IE ?  "426px" : "386px";
        this.els.sendbox.style.width = Prototype.Browser.IE ?  "300px" : "242px";
    },

    //get default or custom image url for male and female
    get_image_url: function(user) {
        if(user.avatar == "custom") {
            return this.chat_options.amazone_avatar_url + "/custom_" + user.id + ".jpg";
        } 
        return  "/images/skins/user_default_" + user.gender + ".jpg";
    },

    //save message throught server side
    data_save: function(message) {
        this._request("/chat/do_send?message="+message+"&room="+this._getRoomName(this.getCurrentPipe()), true);
        
    //        this.core.request.send('setMessage', {
    //            room: this._getRoomName(this.getCurrentPipe()),
    //            user_id: this.chat_options.user_id,
    //            message:message
    //        });

    },

    //copy user name to input
    say_to: function(name) {

        this.say_to_name = name;
        this.els.sendbox.value = this.say_to_name + ": " + this.say_text;
        this.els.sendbox.focus();
    },

    //show panel with smiles list
    show_smiles: function() {
        if(this.chat_options.smile_container.style.display == "none") {
            this.chat_options.smile_container.show();
        } else {
            this.chat_options.smile_container.hide();
        }
    },

    add_smile: function(smile) {
        this.els.sendbox.value += smile;
        this.show_smiles();
        this.els.sendbox.focus();
    },

    //replace :) to image
    make_smiles: function (text) {
        
        text = this.parseMessage(text);

        for (var i = 0; i < this.chat_options.smiles.length; i++) {
            var wr = this.chat_options.smiles[i]['alt'];
            var rp = ' <img src="/images/smiles/' + this.chat_options.smiles[i]['img']+'.gif" border="0" >';

            while(text.indexOf(wr)>-1) text = text.replace(wr, rp);
        }
        return text;
    },

    //Clear messages in current pipe
    clear: function() {
        this.currentPipe.els.messages.innerHTML = "";
    },
    
    // enable/disable auto scroll
    changeAutoscroll: function() {
        this.autoscroll = !this.autoscroll;
    },

    reset: function(){
        this.core.clearSession();
        if(this.els.pipeContainer){
            this.els.pipeContainer.dispose();
            this.els.more.dispose();
        }
        this.core.initialize(this.core.options);
    },

    //UPDATE ONLINE COUNTER 
    update_online: function(value) {
        this.chat_options.online_tag.each(function(item){
            item.innerHTML = Number(item.innerHTML) + value;
            if(Number(item.innerHTML) < 0) {
                item.innerHTML = 0;
            }
        }.bind(this));

        //Users panel, update scolled content
        this.user_scroll.items_count += Number(value);
        this.user_scroll.max_width += (this.user_scroll.step*value);
        var w = this.chat_options.user_container.style.width.replace("px", "");
        
        this.chat_options.user_container.style.width = String(Number(w) + (this.user_scroll.step*value))+"px";
    },

    //show errro tip
    show_warning: function(message, autohide) {
        this.chat_options.error_container.update(new Element("span").insert(message));
        try {
            this.chat_options.error_container.style.width = this.getCurrentPipe().els.messages.offsetWidth + 2 + "px";
        } catch(e) {
            this.chat_options.error_container.style.width = "594px";
        }

        Effect.SlideDown("chat_error_block");
        if(autohide) {
            setTimeout(function(){
                Effect.SlideUp("chat_error_block");
            }.bind(this), 5000);
        }
    },

    //Personal room name created by user id, where less user id should be second
    _getRoomName: function(pipe) {
        var room = pipe.properties.name;

        if(pipe.type == "uni") {
            if(Number(this.user_options.user_id) > Number(pipe.properties.id)) {
                return this.user_options.user_id.toString() + "_" + pipe.properties.id.toString();
            } else {
                return pipe.properties.id.toString() + "_" + this.user_options.user_id.toString();
            }
        } else {
            return room;
        }
    },

    _get_history: function(room, pubid) {
        this._request("/chat/history?room="+room+"&pubid="+pubid);
    },

    _get_users: function(action, name, gender) {
        //action replace or update
        this._request("/chat/users?act="+action+"&name="+name + "&g="+gender);
    },

    _request: function(url, loading) {
        new Ajax.Request(url, {
            asynchronous:true,
            evalScripts:true,
            onLoaded:function(request) {
                hideLoader();
            },
            onLoading:function(request){
                if(!loading) {
                    showLoader();
                    setTimeout(function(){
                        hideLoader()
                    }, 6000);
                }
            }
        });
    },

    _init_filter: function() {
        this.chat_options.filter.observe('change', function(ev){
            ev.stop();
            this._get_users("replace", $("chat_user_name").value, this.chat_options.filter.value);
        }.bind(this));

        $("submit_filter").observe("click", function(ev){
            ev.stop()
            if( document.createEvent ) {
                var e = document.createEvent('HTMLEvents');
                e.initEvent('change', true, true);
                this.chat_options.filter.dispatchEvent(e);
            } else {
                this.chat_options.filter.fireEvent('onchange');
            }
        }.bind(this))
        
    },

    //user panel scroll left
    scroll_left: function() {
        var margin = this.chat_options.user_container.style.marginLeft;
        margin = Number(margin.replaceAll("px", "")) + this.user_scroll.step;
        if(margin > 0) {
            margin = 0;
        }
        this.chat_options.user_container.style.marginLeft = String(margin) + "px";
    },

    //user panel scroll rigth
    scroll_right: function() {
        if(this.user_scroll.per_screen_count > this.user_scroll.items_count)
            return

        var margin = this.chat_options.user_container.style.marginLeft;
        margin = Number(margin.replaceAll("px", "")) - this.user_scroll.step;
        var limit = -this.user_scroll.step*(this.user_scroll.items_count - this.user_scroll.per_screen_count);
        if(margin < limit) {
            margin = limit;
        }
        this.chat_options.user_container.style.marginLeft = String(margin) + "px";
    },

    scroll_reset: function() {
        this.chat_options.user_container.style.marginLeft = "0px";
    }

});

var ImageAvatar = Class.create({
    initialize: function(attributes, gender) {
        attributes = attributes || {};
        attributes["onerror"] = "this.src = '/images/skins/user_default_"+gender+".jpg'"
        this.element = new Element("img", attributes);

    },

    toElement: function() {
        return this.element;
    }
})




var TimeHint = Class.create({
    element:null,
    initialize: function(attributes) {
        this.element = new Element("div", attributes);
    },

    setTime: function(time) {
        var currentTime = new Date().getTime();
        var s = (currentTime - time)/1000;

        var secInHours = 3600;
        var hours   = Math.floor(s / secInHours);
        var days   =  Math.floor(hours / 24);
        var minutes = Math.floor((s - hours * secInHours) / 60);
        var seconds = Math.floor(s - minutes * 60 - hours * secInHours);
        var res_time = "1 second";

        if(Number(days) > 0 ) {
          res_time = days + " day" + this.getTextSuffix(days);
        } else if(Number(hours) > 0) {
          res_time = hours + " hour" + this.getTextSuffix(hours);
        } else if(Number(minutes) > 0) {
          res_time = minutes + " minute" + this.getTextSuffix(minutes);
        } else if(Number(seconds) > 0) {
          res_time = seconds + " second" + this.getTextSuffix(seconds);;
        }
        res_time += " ago";
        this.element.innerHTML = res_time;
    },

    getTextSuffix: function(value) {
        return value > 1 ? "s" : ""
    },

    setPosition: function(x, y) {
        this.element.style.left = x + 12 + "px";
        this.element.style.top  = y + 12 + "px";
    },

    toElement: function() {
        return this.element;
    },

    remove: function() {
        this.element.remove();
    },

    hide: function() {
        this.element.hide();
    },

    show: function() {
        this.element.show();
    }
})
