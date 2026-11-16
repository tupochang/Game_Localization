/*const sqlite3 = require('sqlite3');
var db = new sqlite3.Database('sqlite/database');*/
var load_db = true;
var db;
try {
	db = require('better-sqlite3')('sqlite/database');
}
catch (e) {
	alert("無法在這部電腦上啟用存檔功能。");
	load_db = false;
}

var user_id=1;//override
var game="susu2";
//d = q("select * from users");
////console.log('users',d);
function q(sql){
	if(!load_db) return [];
	//console.log('sql:',sql);
	var rows = db.prepare(sql).all();
	return rows;
}
function qup(sql){
	if(!load_db) return [];
	////console.log('update sql:',sql);
	var result = db.prepare(sql).run();
	return result;
}
function p(sql,obj){
	if(!load_db) return [];
	////console.log('sql:',sql,'obj',obj);
	var rows = db.prepare(sql).all(obj);
	return rows;
}
function pup(sql,obj){
	if(!load_db) return [];
	////console.log('update sql:',sql);
	var result = db.prepare(sql).run(obj);
	return result;
}
  /*db.each("SELECT * FROM Products", function (err, row) {
    ////console.log(row);
  });*/

function m_escape(str){
    if (typeof str != 'string')
        return str;

    return str.replace(/[\0\x08\x09\x1a\n\r"'\\\%]/g, function (char) {
        switch (char) {
            case "\0":
                return "\\0";
            case "\x08":
                return "\\b";
            case "\x09":
                return "\\t";
            case "\x1a":
                return "\\z";
            case "\n":
                return "\\n";
            case "\r":
                return "\\r";
            case "\"":
            case "'":
            case "\\":
            case "%":
                return "\\"+char; // prepends a backslash to backslash, percent,
                                  // and double/single quotes
        }
    });
}
function get_achievement_list(){
	if(!load_db) return [];
	return q("select * from achievements where game='"+game+"'");
}
function add_achievement(obj){
	if(!load_db) return [];
	m_escape(obj.name);
	obj.game = game;
	m_escape(obj.code_name);
	m_escape(obj.description);
	result = q("select * from achievements where code_name='"+obj.code_name+"' and game='"+obj.game+"'");
	//result = q(`select * from achievements where code_name=${obj.code_name} and game=${obj.game}`);
	id = 'null';
	//print_r($result);
	if(result){
		id = result[0]['id'];
	}
	qup(`replace into achievements values (${id},'${game}','${obj.name}','${obj.code_name}','${obj.description}')`);
}
function get_user_achievements(){
	if(!load_db) return [];
	if(user_id){
		result = q(`select * from user_achievements ua join achievements a on ua.achievement_id=a.achievement_id where ua.user_id=${user_id} and a.game='${game}'`);
	}
	else result = [];
	return result;
}
function add_user_achievement(obj){
	if(!load_db) return [];
	if(user_id){
		m_escape(obj.achievement_id);
		if(obj.achievement_id){
			qup(`insert into user_achievements values (${user_id},${obj.achievement_id})`);
		}
	}
	else result = [];
	return result;
}
testobj = {
	name: 'test',
	savepath: 'test/',
	json: 'blahbalh',
	extstate: 'stuffstate',
};
var resultobj;
function db_save_game(obj){
	//console.log('saving game to db',obj);
	if(!load_db) return false;
	if(user_id){
		////console.log('found user_id',user_id);
		/*m_escape(obj['name']);
		m_escape(obj['savepath']);
		m_escape(obj['json']);
		m_escape(obj['extstate']);*/
		if(obj.name){
			////console.log(`select save_id from user_saves where user_id=${user_id} and name='${obj.name}'`);
			var result= q(`select save_id from user_saves where user_id=${user_id} and name='${obj.name}'`);
			////console.log('save_id result',result,result.length,result[0]);
			/*save_id = 'null';
			////console.log('resultstats',result.length,result[0]);
			for(i in result){
				////console.log(i,result[i]);
			}*/

			//throw new Error("my error message");
			if(result.length > 0 && result[0]['save_id']){
				if(obj.name!='newgamestart'){
					var r = confirm("這會覆蓋現有存檔，確定要繼續嗎？");
				}
				if(r || obj.name=='newgamestart'){
					save_id = result[0]['save_id'];
					////console.log(`replace into user_saves values (${save_id},${user_id},'${obj.name}','${obj.savepath}','${obj.json}','${obj.extstate}',CURRENT_TIMESTAMP)`);

					stmt = db.prepare(`replace into user_saves values (?,?,?,?,?,?,?,?,CURRENT_TIMESTAMP)`);
					stmt.run(save_id,user_id,obj.name,obj.savepath,obj.json,obj.state,obj.extstate,obj.extdata);
				}

			}
			else {
				//print("insert into user_saves values (null,$user_id,'obj[name]','',``,``,CURRENT_TIMESTAMP)");
				//console.log('sql',`insert into user_saves values (null,${user_id},'${obj.name}','${obj.savepath}','${obj.json}','${obj.extstate}',CURRENT_TIMESTAMP)`);
				stmt = db.prepare(`insert into user_saves values (null,?,?,?,?,?,?,?,CURRENT_TIMESTAMP)`);
                //console.log('sql',`insert into user_saves values (null,${user_id},'${obj.name}','${obj.savepath}','${obj.json}','${obj.state}','${obj.extstate}','${obj.exdata}',CURRENT_TIMESTAMP)`);
				stmt.run(user_id,obj.name,obj.savepath,obj.json,obj.state,obj.extstate,obj.extdata);

				//qup(`insert into user_saves values (null,${user_id},'${obj.name}','${obj.savepath}','${obj.json}','${obj.extstate}',CURRENT_TIMESTAMP)`);
			}
		}
	}
	return true;
}

function db_load_game(load_id){
	//console.log("db load game",load_id);
	emptyret  = {
		savepath: false,
		json: '{}',
		state: '{}'
	}
	if(!load_db) return emptyret;
	if(load_id && load_id > 0){
		result = q(`select * from user_saves where save_id=${load_id}`);
		//console.log('ret',result);
	}
	if(result[0]) ret = result[0];
	else ret = emptyret; 

	return ret;
}
function db_check_newgame_set(){
	if(!load_db) return false;
	result = q(`select * from user_saves where name='newgamestart'`);
	//console.log('ret',result);
	if(result[0]){
		if(result[0]['save_id']==2){
			console.log("deleting old save for restart");
			qup(`delete from user_saves where name='newgamestart'`);
			return false;
		}

	}
	else if(result[0]) return true;
	else return false;
}
function db_load_game_by_name(load_id){
	//console.log("db load game by name",load_id);
	emptyret  = {
		savepath: false,
		json: '{}',
		state: '{}'
	}
	if(!load_db) {
	    console.log("load_db set to false so can't load game");
	    return emptyret;
    }
	if(load_id){
		result = q(`select * from user_saves where name='${load_id}'`);
		console.log('load game result ret',result);
	}
	if(result[0]) ret = result[0];
	else ret = false;

	return ret;
}
function db_get_savepath(obj){
	if(!load_db) return [];
	if(user_id){
		m_escape(obj['name']);
		if(obj['name']){
			result = q(`select savepath from user_saves where user_id=$user_id and name='${obj[name]}'`);
		}
	}
	else result = [];
	savepath = result[0]['savepath'];
	return savepath;
}
function check_savepoint(){
	obj = {
		name:'savepoint'
	};
	if(!load_db) return obj;
	if(user_id){
		m_escape(obj['name']);
		if(obj['name']){
			result = q(`select json from user_saves where user_id=${user_id} and name='${obj.name}'`);
		}
	}
	else result = [];
	if(!result) return false;
	else return true;
}
