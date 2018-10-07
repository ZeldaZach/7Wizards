/* Register a CMD that require user to be loged (sessid needed) */
	Ape.registerCmd("leaveuni", true, function(params, infos) {
		/* Send a row to the given pipe (pubid) */
		Ape.getPipe(params.pipe).sendRaw("INFO", {"action":"userLeave"}, {
			from: infos.user.pipe /* (optional) User is attached to the raw */
		});
	});
