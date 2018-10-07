var userlist = new $H;

Ape.registerHookCmd("connect", function(params, cmd) {

    if (!$defined(params.name)) return 0;

    if (params.level < 3) return ["050", "REQUIRED_LEVEL"]
    
//  TODO
//    var request = new Http('http://www.google.fr/');
//    request.getContent(function(result) {
//        Ape.log(result);
//    });

    if (userlist.has(params.name.toLowerCase())) return ["007", "NICK_USED"];
    if (params.name.length > 30 || params.name.test('[^a-z_A-Z0-9\-]', 'i')) return ["006", "BAD_NICK"];

	
    cmd.user.setProperty('name', params.name);
    cmd.user.setProperty('id', params.id);
    cmd.user.setProperty('gender', params.gender);
    cmd.user.setProperty('avatar', params.avatar);
    cmd.user.setProperty('level', params.level);
    cmd.user.setProperty('blocked', params.blocked);
	
    return 1;
});

Ape.addEvent('adduser', function(user) {
    userlist.set(user.getProperty('name').toLowerCase(), user.pubid);
});

Ape.addEvent('deluser', function(user) {
    userlist.erase(user.getProperty('name').toLowerCase());
});

Ape.registerCmd("block", false, function(params, infos) {
    var pubid = userlist.get(params.username.toLowerCase());
    var user = Ape.getUserByPubid(pubid);
    user.setProperty("blocked", true);
    
    user.pipe.sendRaw("ban", {
        "blocked":true,
        "reason":params.reason
        });
});
