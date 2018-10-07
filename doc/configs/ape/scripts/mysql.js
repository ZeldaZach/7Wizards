    function MySQLConnect(ip, user, password, database) {
        var sql = new Ape.MySQL(ip + ":3306", user, password, database);
 
        //onConnect callback
        sql.onConnect = function() {
            Ape.log('You are now connected to MySQL server');
        }
 
        //onError callback
        sql.onError = function(errorNo) {
            Ape.log('Connection error ' + errorNo +' '+ this.errorString());
        }   
 
        return sql;
    }

    function formatDate(date) {
	  return date.getFullYear() + '-' +
	    (date.getMonth() < 9 ? '0' : '') + (date.getMonth()+1) + '-' +
	    (date.getDate() < 10 ? '0' : '') + date.getDate() + ' ' +
	    (date.getHours() < 10 ? '0' : '') + date.getHours() + ':' +
	    (date.getMinutes() < 10 ? '0' : '') + date.getMinutes() + ':' +
	    (date.getSeconds() < 10 ? '0' : '') + date.getSeconds();
	}
 
    //connect to MySQL Server
    /**
     * /!\ You must specify a user and password, mysql module does not support yet connecting with a user without password. /!\
     */
    var sql = MySQLConnect('127.0.0.1', 'root', '1', 'wizards_dev');
 
 
    //Set up a pooller to send keep alive request each 2minutes
    (function() {
        sql.query('SELECT 1', function(res, errorNo) {
            if (errorNo == 8) {//Something went wrong, connection has been closed
                sql =  MySQLConnect('127.0.0.1', 'root', '1', 'wizards_dev'); //Reconnect to MySQL Server
            }
        }.bind(this));
    }).periodical(1000*60*2);
 
    //Register getInfo command
    Ape.registerCmd('getHistory', true, function(params, cmd) {
	sql.query('select id, name, gender, avatar, chat_activity_time from users where chat_room = "' + params.room + '" order by chat_activity_time desc limit 20', function(res, errorNo) {
             if (errorNo) {
                Ape.log('Request error : ' + errorNo + ' : '+ this.errorString());
                return ['101', 'MYSQL_ERROR'];
            } else {
               cmd.sendResponse('chatusers', {list:res, pubid:params.pubid});
             }

        });
        //Get data from mysql table
        sql.query('select name, message from chats left join users on (users.id = chats.user_id ) where room="'+ params.room+'" order by chats.id desc limit 40', function(res, errorNo) {
             if (errorNo) {
                Ape.log('Request error : ' + errorNo + ' : '+ this.errorString());
                return ['101', 'MYSQL_ERROR'];
            } else {
                //Display to logs data received from mysql
                //Ape.log('Fetching ' + res.length + ' result(s)');
 
              //  Ape.log('- MSG : ' + res[0].message );
 
                cmd.sendResponse('history', {history:res, pubid:params.pubid});//Send first result to client
            }
        });
    });

   Ape.registerCmd('setMessage', true, function(params, cmd) {
        //Get data from mysql table
	var current_date = formatDate(new Date());
        sql.query('INSERT INTO chats(user_id, message, room, created_at, updated_at) VALUES('+ Ape.MySQL.escape(params.user_id)+ ', "' + Ape.MySQL.escape(params.message)+'", "' +
		 Ape.MySQL.escape(params.room) + '", "' + current_date +'", "' + current_date +'")', function(res, errorNo) {
             if (errorNo) {
                Ape.log('Request error : ' + errorNo + ' : '+ this.errorString());
                return ['101', 'MYSQL_ERROR'];
            } else {
                //Display to logs data received from mysql
                //Ape.log('Fetching ' + res.length + ' result(s)');
 
              //  Ape.log('- MSG : ' + res[0].message );
 
                //cmd.sendResponse('history', {history:res});//Send first result to client
             }
        });
    });

    
