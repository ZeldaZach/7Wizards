var SevenWizards = {
    partner: {
        last_hash:null,
        dFrame:null,
        install: function(config) {
            var search = location.search.replace(/^\?{1}/, '').split('&');
            var params = {};
            for (var i=0; i<search.length; i++) {
                var kv = search[i].split('=');
                params[kv[0]]=kv[1];
            }


            this.createCookie('7wz_partner', config['partner'], 30);
            
            var url = "http://www.7wizards.com/";
            // activation
            if ( params['ch'] !== undefined ) {
                url += "visitor/confirm_mail?ch="+params['ch']+"&";
            } else if(params['rh'] !== undefined) {
                url += "visitor/change_password?rh="+params['rh']+"&";
            } else if(params['uh'] !== undefined) {
                url += "visitor/unsubscribe?uh="+params['uh']+"&";
            } else {
                url += "?";
            }
            url += "partner="+config['partner']

            // simple installation
            SevenWizards.partner.dFrame = document.createElement("iframe");

            SevenWizards.partner.dFrame.id = "7wizards_frame";
            SevenWizards.partner.dFrame.src = url;
            SevenWizards.partner.dFrame.style.height = "600px";
            SevenWizards.partner.dFrame.style.width = "100%";
            //SevenWizards.partner.dFrame.style.overflow = "hidden";
            SevenWizards.partner.dFrame.scrolling = "no";
            
            document.getElementById("7wizards_content").appendChild(SevenWizards.partner.dFrame);

        },

        createCookie:function(name, value, days, secure) {
            var date = new Date();
            date.setTime(date.getTime()+(days*24*60*60*1000));
            var expires = "; expires="+date.toGMTString();
            document.cookie = name+"="+value+expires+"; path=/; "+((secure) ? "; secure" : "")+"host="+document.location.host;
        }

    }
    
}

function checkForMessages() {
    if(location.hash != SevenWizards.partner.last_hash){
        SevenWizards.partner.last_hash = location.hash;
        SevenWizards.partner.dFrame.style.height = location.hash.replace(/\#/, "") + "px";
    }
}