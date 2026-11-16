// Debug Logging

var debuglog = function(){}
function set_debuglevel(num){
    debuglevel = num;
    if (debugmode && debuglevel >= 3){
        debuglog = console.log.bind(window.console,'%c%s','background:lightblue; color:black');
        debuglog2 = console.log.bind(window.console,'%c%s','background:lightgreen; color:black');
    }
    else if (debugmode && debuglevel >= 2){
        debuglog = function(){}
        debuglog2 = console.log.bind(window.console,'%c%s','background:lightgreen; color:black');
    }
    else{
        debuglog = function(){}
        debuglog2 = function(){}
    }
}
storyid = new Map();
customClasses = [];
prevcustomClasses = [];
storyContainer = document.querySelector('#story');
var enablesavepath = true;
var freshload = true;

storycount = 0;
//debuglevel=3;
debuglevel=3;
set_debuglevel(debuglevel);
enable_sound=true;
function isset(variable){
    if(typeof(variable) != "undefined" && variable !== null) {
        return true;
    }
    else return false;
}

function w(msg){
    if(debugmode && debuglevel >= 2) {
        console.log("%cWARNING: "+msg+" ",'background: yellow; color: black');
    }
}
function e(msg){
    if(debugmode && debuglevel >= 1){
        debuglog("%cFATAL ERROR: "+msg+" ",'background: darkred; color: white');
        console.trace();
    }
}
function fatal(msg){
    console.log("%cFATAL ERROR: "+msg+" ",'background: darkred; color: white');
    console.trace();
}
function n(msg){
    if(debugmode && debuglevel >= 3) console.log("%cNOTICE: "+msg+" ",'background: lightgreen; color: black');
}
function vdump(obj,msg='',dotrace=false){
    if(debugmode && debuglevel >= 3){
        if(dotrace) console.trace();
        console.log('%c'+msg,' background: lightblue; color: black',obj);
    }
}

///////////////////////////////////
// Initialize variables
///////////////////////////////////
var state 		    = {};
state.firstclick    = true;
state.sound_cache   = {};
state.flag_map 	    = {};
state.spineflags    = Array();
state.scrolled 	    = 0;
state.loaded 	    = false;
state.choicelock    = false;
state.choicevisible = false;
state.skip_fadein = true;

var	gamestate    = {},
    newgamestate = {},
    watchvars_arr = [],
    _inkStory    = null,
    profile_arr  = [];

var	sound_loaded = stopset = autocontinue = updated_scene = updated_sceneoverlay = updated_scenemid = false;
var continuedisabled = skip = newchoices = doautochoices = false;
var choicedelay      = 0,
    pcount       	 = 1;
loadinggame = false;

state.enable_shortcuts = false;
state.enable_shortcuts_delay = 500;//timeout disabled sometimes it will cause events to mistime each other and misbehave
///////////////////////////////////
// Global Events - code that runs when certain events happen
// all events start with evt_
// they operate much the same as hooks
// the code is forced to stay in one place for events this way
// and there is a strong potential of far less overhead since javascript event handling can be inefficient
// if we ever NEED object specific events where they share a name but have different behaviors for which context they have, we could use trigger
// but avoiding them if possible makes the game easier to code, understand, debug, develop and run better
///////////////////////////////////

//when a player picks a choice, and the choice box has been cleared
function evt_choices_picked(){
    state.enable_shortcuts = false;
}

//when new choices are added and the animation ends and shows it to the player
function evt_choices_new_shown(){
    //state.enable_shortcuts = false;
    state.enable_shortcuts = true;
    /*setTimeout(function(){
        //state.enable_shortcuts = true;
    }, state.enable_shortcuts_delay);*/
}
//a choice shortcut key was pressed
function evt_choice_keydown(keyCode){
    state.enable_shortcuts = false;
}

//inky command pause was called
function evt_scripted_pause(){
    continuedisabled=true;
    state.enable_shortcuts = false;
}

//inky command pause has ended
function evt_scripted_unpause(){
    continuedisabled=false;
    //state.enable_shortcuts = true;
}

//inky command pause had time 0 or stop
function evt_scripted_pausestop(){
    continuedisabled=false;
    stopset=true;
}

//inky command pause had negative time
function evt_scripted_pause_negative(){
}

//continue has started
function evt_continue_start(){
}
//continue button animation has finished after being clicked
function evt_continue_button_animate_end(){

}
//continue has ended
function evt_continue_end(){
    //do cleanup
    let removed_num =  $("#story p.parsed.hide").length;
    //console.log("before cleanup pcount",pcount,'num removing',removed_num);
    $("#story p.parsed.hide").remove();
    pcount = pcount-removed_num;
    //console.log("after cleanup pcount",pcount);
}
//more examples
function evt_fixhtml_start(){}
function evt_fixhtml_end(){}
function evt_parsetext_start(ele){}
function evt_parsetext_end(ele){}
function evt_playsound(soundref){}
function evt_choice_click_start(event){}
function evt_choice_click_end(event){
//	$("#story").getNiceScroll()[0].lazyResize(30);
}
//custom events way with triggers but not used this way for reasons explained above
/*$(document).on("choices_picked",function(){
	enable_shortcuts = false;
});
$(document).on("choices_new_shown",function(){
	setTimeout(function(){
		enable_shortcuts = true;
	}, enable_shortcuts_delay);
});*/

///////////////////////////////////
// Regex Patterns for Inky Parsing
///////////////////////////////////
// Requires an update function, ex. updateportrait
var updatepatterns = {
        /* portnpc:/portnpc:([^ ]*)/,
         portplayer:/portplayer:([^ ]*)/,
         currency:/cur!([^\s]*)/
        */
    },
    updatefilters = {
    },
    updatetextpatterns = {
    },
// unusedpatterns = {
// 	spine:[/spine:"([^"]+)"/,""]
// 	portplayer:/portplayer:([^ ]*)/,
// 	fx:[/'''(.+)'''/,"<i class='sfx'>*\$1*</i>"],
// 	sub:[/_center_(.+)_center_/mg,"<span class='sub centersub'>\$1</span>"],
// 	bold:[/!!(.+)!!/mg,"<b class='bolder'>\$1</b>"],
// 	italic:[/``(.+)``/mg,"<i class='italics'>\$1</i>"],
// 	tags:[/([a-zA-Z]+)\!!(.*)/,"<div class='\$1 textcolumn'>\$2 </div>"],
// 	images:[/\b\^([^\^.]*).{0,1}([^\^]*)\^/mg,"<img src=\"\$1.png\" class=\"storyimg\" id=\"\$2\">"],
// 	names:[/\b%([^%.]*).{0,1}([^%]*)%/mg,"<i class='italics'>\$1</i>"],
// },
    replacepatterns = {
        achievements:[/\bachievements:([^ <]+)/,""],
        portnpc:[/\bportnpc:([^ ]*)/,"<img src='angel/\$1' class='portrait portrait-npc'>"],
        howler:[/\bhowler:([^:]*):"([^"]*)"/,""],
        portrait_add:[/\bportrait_add:([^:]*):([^:]*):([^:]*):([^ ]*)/,""],
        portrait_activeone:[/\bportrait_activeone:([^ ]*)/,""],
        portrait_active:[/\bportrait_active:([^ ]*)/,""],
        portrait_unactive:[/\bportrait_unactive:([^ ]*)/,""],
        portrait_dismiss:[/\bportrait_dismiss:([^ ]*)/,""],
        pause:[/\bpause:([^ ]+)/,""],
        call_event:[/\bcall_event:([^ ]+)/,""],
        textbox_class:[/\btextbox_class:([^ ]+)/,""],
        set_var:[/\bset_var:([^ ]+)/,""],
        clear:[/\bclear:([^ ]+)/,""],
        save:[/\bsave:([^ <]+)/,""],
        saveto:[/\bsaveto:([^ <]+)/,""],
        /*update_ui:[/\bupdate_ui:"([^"]+)"/,""],*/
        icall:[/\bicall:"([^"]+)"/,""],
        /*sync_watchvars:[/\bsync_watchvars:/,""],*/
        load:[/\bload:([^ ]+)/,""],
        loadraw:[/\bloadraw:([^ ]+)/,""],
        url:[/\burl:([^:]+):([^:]+):/,"<a href=\"http://\$1\" target=\"_blank\">\$2</a>"],
        surl:[/\burl:([^:]+):([^:]+):/,"<a href=\"https://\$1\" target=\"_blank\">\$2</a>"],
        set_clicksound:[/\bset_clicksound:([^ ]+)/,""],
        set_choice_clicksound:[/\bset_choice_clicksound:([^ ]+)/,""],
        //since lowest in the list it will run last
        refresh_ui:[/\brefresh_ui:/,""],
        //rflag:[/\brflag:/,""],
        /*b_enable:[/\bb_enable:/,""],
        b_disable:[/\bb_disable:/,""],*/
        unlock_achievement:[/\bunlock_achievement:([^ ]+)/,""],
        lock_achievement:[/\block_achievement:([^ ]+)/,""],
    },
    recursive_replacepatterns = {
        newline:[/\b_n_/,"<br>"],
    };
const uichoice    = /([_][__])(?:(?!\1|\\).|\\.)*\1/;


////////////////////////////////////////////
// Regex and parsing functions
////////////////////////////////////////////
String.prototype.matchAll = function(regexp) {
    var matches = [];
    this.replace(regexp, function() {
        var arr = ([]).slice.call(arguments, 0);
        var extras = arr.splice(-2);
        arr.index = extras[0];
        arr.input = extras[1];
        matches.push(arr);
    });
    return matches.length ? matches : null;
};
function multi_match(str,regex,ele){
    var temptext = str;
    var matches = [];
    var mfound = true;
    match = str.match(regex);
    //debuglog('multi_match',match);
    if(match && match[1]){
        while(mfound){
            match = temptext.match(regex);
            temptext = temptext.replace(regex,"");
            if(!match){
                mfound=false;
            }
            else {
                matches.push(match);
                //debuglog('temptext',temptext,matches);
            }
        }
        newtext = temptext;
        ele.html(newtext);
        return matches;
    }
    else return false;
}
//Anote#22
// add methods to strings
String.prototype.replaceAt = function (index, replacement) { return this.substr(0, index) + replacement+ this.substr(index + replacement.length); };
String.prototype.removeAt  = function (index, howMuch) { return this.substr(0, index) + this.substr(index + howMuch); };
String.prototype.insertAt  = function (index, text) { return this.substr(0, index) + text + this.substr(index); };
//Anote#23
// utility function to take our custom inky syntax and split it smartly, based
// on if it's a text parameter or a JSON paramter containing infinite
// properties basically ran for any parsable object in inky that has :
// parameters
function split_objstr(objstr){
    estr = objstr;
    splitstr = estr.split(':');
    val = splitstr[0];
    splitstr2 = estr.split('"');
    debuglog(splitstr,splitstr2);
    if(!splitstr2[1]){
        splitstr2 = estr.split("'");
    }
    eobj = {};
    eobj.value = val;
    //if(splitstr[1]) eobj.json = JSON5.parse("{"+splitstr2[1]+"}");
    if(splitstr[1]) eobj.json = parse_json(splitstr2[1]);
    return eobj;
}


////////////////////////////////
//Asset loading
////////////////////////////////
// vdump(visualassets,'running PIXI.Loader.shared on visual assets');
state.sound_preload = soundassets;
var loader = PIXI.Loader.shared;
//loader.onError.add(loader_error);
//function loader_error(a,b,c){
//console.log('error:',a,b,c);
//}
loader.add(visualassets).add(state.sound_preload).on('progress',loadingbar).load(prerungame);
function loadingbar(var1,var2,var3){
    console.log('loading ',var2.name);
    $("#loading .bar").css('width',var1.progress+'%');
    // debuglog('Loading',var1.progress);
}


////////////////////////////////////////////
// Asset validation
////////////////////////////////////////////
function check_spine(imgstr){
    var tsplit = imgstr.split(":");
    if(tsplit[0].indexOf('.json') !== -1){
        return true;
    }
    else return false;
}
function check_spine_file(filename){
    if(!PIXI.Loader.shared.resources[filename]) {
        w("Could not load "+filename+" as it wasn't in the preloader");
        return false;
    }
    if(!PIXI.Loader.shared.resources[filename].spineData) {
        w("Could not load "+filename+" as it does not have spineData");
        return false;
    }
    return true;
}
function check_sound_file(filename){
    if(!PIXI.Loader.shared.resources[filename]) {
        w("Could not load "+filename+" as it wasn't in the preloader");
        return false;
    }
    return true;
}
function check_file(filename){
    if(!PIXI.Loader.shared.resources[filename]) {
        w("Could not load "+filename+" as it wasn't in the preloader");
        return false;
    }
    if(!PIXI.Loader.shared.resources[filename].texture) {
        w("Could not load "+filename+" as it does not have a texture");
        return false;
    }
    return true;
}
/*$(window).on('beforeunload', function () {
	for(i in state.sound_cache){
		state.sound_cache[i].unload();
	}
	alert("you leaving this page");
	return false;
});*/

///////////////////////////////////
// Reader initialization
///////////////////////////////////
// Anote#A1
// PIXI Resource Loader => calls loading bar on each asset loaded into the browser
// => calls prerungame callback on completion
// => prerungame calls load_objects which sets up all the objects for the reader to use based on inky settings
// => load_objects returns, prerungame makes ajax calls for achievements and user settings, when finished calls
// => rungame which sets up the PIXI canvas and stage and starts its animation loop, if PIXI is being used
// => startstory is called which runs after $(document).ready and fires up the
// inky story at last this is ran once and assigns the click event to continue
// and does the final setup and tying into inky
function prerungame(){
    vdump(state.sound_preload,'loading Howler sound assets');
    if(!debugmode) { assign_rightclick() }

    load_objects();

    //$.when(get_achievement_list(),get_user_achievements()).done(function(){
    $.when().done(function(){
        var flags = _inkStory.variablesState.flags;
        if(flags){
            //flags_arr = JSON5.parse("{"+flags+"}");
            flags_arr = parse_json(flags);
            //debuglog('found flags',flags);
            vdump(flags_arr,'found arr');
            for(var i in flags_arr){
                var v = flags_arr[i];
                v = v.trim();
                //debuglog('achievements',state.flag_map,i,v);
                //var objstr = _inkStory.variablesState["flag_"+i];
                var objstr = v;
                state.flag_map[i] = objstr;
                //debuglog('flag_map',state.flag_map);
                //debuglog('seting t/f for',objstr);
                var truefalse = check_user_achievement(i);
                //debuglog('user_achievements',user_achievements,truefalse,objstr);
                _inkStory.variablesState["flag_"+i] = truefalse;
                //debuglog('achievement '+ i +'in ink set to ',truefalse,_inkStory.variablesState['flag_'+i]);
                //debuglog('set flag_'+v+' to ',_inkStory.variablesState['flag_'+v]);
            }
        }
        else {
            w("no flags found");
        }
        if(typeof textstyle_forcefade == "undefined"){
            textstyle_forcefade = false;
        }
        if (typeof hook_onstart != "undefined") hook_onstart();
        rungame();
    });
}
var registry = [];
function check_registry(){
    result = q("SELECT name FROM sqlite_master WHERE type='table' AND name='registry'");
    console.log("checking registry table",result);
    if(result.length==0){
        qup(`
            create table registry
            (
                id    integer                                not null primary key autoincrement,
                key varchar (255) default '' not null,
                value varchar(255) default ''                not null,
                date  datetime     default current_timestamp not null
            )
        `);
        qup(`
            create unique index idx_registry_kv_pairs on registry (key, value);
        `);
    }
}
function load_registry() {
    console.log('loading the registry');
    check_registry();
    result = q("select * from registry");
    for(let r in result){
        let row = result[r];
        registry[row['key']] = row['value'];
        _inkStory.variablesState[row['key']] = row['value'];
        console.log('setting registry','key',row['key'],'value',row['value'],'inky',_inkStory.variablesState[row['key']]);
        if(row['key'].startsWith("ACHIEVEMENT_")){
            let split = row['key'].split("ACHIEVEMENT_");
            //console.log('achievements split',split);
            let akey = split[1];
            if(achievements[akey]){
                achievements[akey].status = row['value'];
                achievements[akey].code = akey;
            }
            else debuglog("achievement does not exist in achievements.js: ",akey);
        }
    }
}
function print_inky_vars(){
    let ivars_globals = _inkStory.variablesState._globalVariables;
    let ivars= _inkStory.variablesState;
    for(let varname in ivars_globals){
        console.log(varname,"=",ivars[varname]);
    }
}
function unlock_achievement(ivarname) {
    let ivars= _inkStory.variablesState;
    console.log('inkstory achievement ',ivarname,ivars["ACHIEVEMENT_"+ivarname]);
    if(!achievements[ivarname].status || achievements[ivarname].status==0){
        ivars["ACHIEVEMENT_"+ivarname] = 1;
        update_registry("ACHIEVEMENT_"+ivarname,1);
        achievements[ivarname].code = ivarname;
        achievements[ivarname].status = 1;
        console.log('achievements',achievements[ivarname]);
        displayAchievement(achievements[ivarname]);
    }
}
function lock_achievement(ivarname) {
    let ivars= _inkStory.variablesState;
    ivars["ACHIEVEMENT_"+ivarname] = 0;
    achievements[ivarname].status = 0;
    update_registry("ACHIEVEMENT_"+ivarname,0);
}
function update_registry(ivarname,ivalue){
    console.log(`select * from registry where key='${ivarname}'`);
    result = q(`select * from registry where key='${ivarname}'`);
    id = 'null';
    if(typeof result[0] != 'undefined'){
        id = result[0]['id'];
    }
    console.log(`replace into registry values (${id},'${ivarname}','${ivalue}',CURRENT_TIMESTAMP)`);
    qup(`replace into registry values (${id},'${ivarname}','${ivalue}',CURRENT_TIMESTAMP)`);
    registry[ivarname] = ivalue;
}
/*function update_rflags(){
    let ivars_globals = _inkStory.variablesState._globalVariables;
    let ivars= _inkStory.variablesState;
    for(let varname in ivars_globals){
        if(varname.startsWith("rflag_")){
            let ivalue = m_escape(ivars[varname]);
            let ivarname = m_escape(varname);
            console.log(`select * from registry where key='${ivarname}' and value='${ivalue}'`);
            result = q(`select * from registry where key='${ivarname}' and value='${ivalue}'`);
            id = 'null';
            if(typeof result[0] != 'undefined'){
                id = result[0]['id'];
            }
            console.log(`replace into registry values (${id},'${ivarname}','${ivalue}',CURRENT_TIMESTAMP)`);
            qup(`replace into registry values (${id},'${ivarname}','${ivalue}',CURRENT_TIMESTAMP)`);
            registry[varname] = ivars[varname];
        }
    }
}*/

//Anote#13
// This doesn't load assets, that's the pixi loaders job and by this point has
// already run this takes those assets as well as things defined in inky and
// sets up all the javascript objects in a way that the reader expects based
// on what is defined in inky
function load_objects(){
    state.skip_fadein = !disable_fadein_check;
    if(enable_sound){
        for(var i in state.sound_preload){
            var v = state.sound_preload[i];
            file_loaded = check_sound_file(v);
            if(file_loaded){
                sresource = PIXI.Loader.shared.resources[v];
                state.sound_cache[v] = new Howl({
                    src: sresource.url,
                    volume:0.1,
                });
            }
            //debuglog('creating howl',v,state.sound_cache[v]);
        }
        sound_loaded = true;
    }
    /*for(var i in state.sound_cache){
        v = state.sound_cache[i];
        //v.unload();
    }*/

    sprite_list = {};
    portrait_list = {};
    render_width = Number(_inkStory.variablesState["render_width"]);
    render_height = Number(_inkStory.variablesState["render_height"]);
    box_size = _inkStory.variablesState["box_size"];
    use_pixi = _inkStory.variablesState["use_pixi"];
    //debuglog("ink obj",_inkStory._state._variablesState["use_pixi"]);
    //debuglog("ink use_pixi",_inkStory.variablesState["use_pixi"]);
    //str = JSON.stringify(_inkStory, getCircularReplacer());
    //debuglog('ink json',str);
    //use_pixi = true;
    n('use_pixi '+use_pixi);

    check_savepoint();

    //debuglog(story);
    var pixivars = _inkStory.variablesState["pixivars"];
    var anchors = _inkStory.variablesState["anchors"];
    var anchors_reset_str = _inkStory.variablesState["anchors_reset"];

    if(pixivars && anchors){
        pixivars = pixivars.replace(/ /g,"");
        anchors = anchors.replace(/ /g,"");
        anchors_reset_str = anchors_reset_str.replace(/ /g,"");
        pixivars_arr = pixivars.split(",");
        anchors_arr = anchors.split(",");
        //anchors_arr = anchors_arr.reverse();
        //debuglog('anchors',anchors_arr);
        //anchors_arr.reverse();
        anchors_reset = anchors_reset_str.split(",");
        //debuglog(pixivars_arr,anchors_arr,'reset',anchors_reset);

        for(var i in pixivars_arr){
            var v = pixivars_arr[i];
            state[v] = _inkStory.variablesState[v];
            //debuglog(v,state[v]);
        }

        //debuglog('setstory',render_width,render_height);
        //renderer = PIXI.autoDetectRenderer(render_width, render_height, {backgroundColor : 0x222222});
        pixi_render_options.width = render_width;
        pixi_render_options.height = render_height;
        renderer = PIXI.autoDetectRenderer(pixi_render_options);
        // create the root of the scene graph, this is the parent container which given to the renderer
        stage = new PIXI.Container();
        /*scene_container = new PIXI.Container();
        scene_container.position.y = box_size+10;
        scene_container.z = 40;

        port_container = new PIXI.Container();
        port_container.position.x = 0;
        port_container.position.y = 0;
        port_container.z = 50;
        var fillg = new PIXI.Graphics();
        fillg.beginFill(0x00FFFF, 0);
        fillg.drawRect(0, 0, render_width, render_height);
        //debuglog('render',render_width,render_height);
        fillg.endFill();
        port_container.addChild(fillg);
        //port_container.position.x = render_width/2;
        //port_container.position.y = render_height;

        spine_container = new PIXI.Container();
        spine_container.position.x = 0;
        spine_container.position.y = 0;
        spine_container.z = 60;
        //stage.addChild(graphics);
        //debuglog('anchors',anchors_arr);

        top_container = new PIXI.Container();
        top_container.position.x = 0;
        top_container.position.y = 0;
        top_container.z = 70;*/
        ancr_containers = {};
        filter_map = {};
        vdump(anchors_arr,'anchors');

        zcount = 0;
        for(var i in anchors_arr){
            zcount++;
            var v = anchors_arr[i];
            v = v.trim();
            var objstr = _inkStory.variablesState["ancr_"+v];
            var aref = ancr_containers[v] = state['acontainer_'+v] = new PIXI.Container();
            if(objstr){
                objstr = "{" + objstr + "}";
                n('objstr '+objstr);
                //var obj = JSON5.parse(objstr);
                var obj = parse_json(objstr);

                aref.offsetx = aref.position.x = obj.x;
                aref.offsety = aref.position.y = obj.y;
                aref.centerme = obj.center;
                aref.centermey = obj.centery;
                aref.visible = true;
                aref.z = zcount*10;
                aref.cname = v;

                if(obj.type == 'image'){
                    var resource = PIXI.Loader.shared.resources[obj.value];
                    if(PIXI.Loader.shared.resources[obj.value]) state[v+'_sprite'] = new PIXI.Sprite(PIXI.Loader.shared.resources[obj.value].texture);
                    else state[v+'_sprite'] = new PIXI.Sprite();
                    var spriteref = state[v+'_sprite'];

                    spriteref.visible=true;
                    /*spriteref.position.x = obj.x;
                    spriteref.position.y = obj.y;
                    spriteref.offsetx = obj.x;
                    spriteref.offsety = obj.y;
                    spriteref.centerme = obj.center;
                    spriteref.centermey = obj.centery;
                    spriteref.z=zcount;*/
                    if(obj.width) spriteref.width = eval(obj.width);
                    if(obj.height) spriteref.height = eval(obj.height);

                    regexstr = "\\b"+v+":([^\n< ]*)";
                    updatepatterns[v] = new RegExp(regexstr);
                    sprite_list[v] = state[v+'_sprite'];
                    aref.addChild(state[v+'_sprite']);
                    //if(obj.ztop) top_container.addChild(state[v+'_sprite']);
                    //else scene_container.addChild(state[v+'_sprite']);

                    //state[v+'_spine'] = new PIXI.spine.Spine(PIXI.Loader.shared.resources[spinefile].spineData);

                    //Anote#34
                    // setup spine so can dynamically switch to spine if we
                    // have to using the same anchor we can only load via
                    // object creation so store the properties and merge later
                    // state[v+'_spine'] = new PIXI.spine.Spine(PIXI.Loader.shared.re
                    // sources[spinefile].spineData);

                    state[v+'_spineprops'] = {};
                    var spineref = state[v+'_spineprops'];
                    var spinefile = obj.value;
                    /*debuglog('spinefile',spinefile,v,obj);
                     set the position
                    if(obj.x) spineref.x = obj.x;
                    if(obj.y) spineref.y = obj.y;*/
                    spineref.center = obj.center;
                    spineref.centery = obj.centery;
                    spineref.visible = true;
                    /*spineref.ztop = obj.ztop;
                    spineref.z=zcount;

                    regexstr = v+":([^\n ]*)";
                    updatespinepatterns[v] = new RegExp(regexstr);
                    debuglog('in obj.type spine',updatespinepatterns,v);
                    debuglog('in obj.type spine',updatespinepatterns,v);
                    scene_container.addChild(state[v+'_spineprops']);*/
                }

                else if(obj.type == 'filter'){
                    if(!stage.filters) stage.filters = new Array();
                    if(!state.filter_arr) state.filter_arr = [];
                    if(!state.filter_map) state.filter_map = {};

                    //
                    if(obj.value=="crt"){
                        //var crtFilter = new CRTFilter();
                        state.filter_map["crt"] = new CRTFilter;

                        var l = stage.filters.length;
                        stage.filters = [state.filter_map.crt];
                        //push isn't working...
                        //debuglog("pushing filter onto stage",stage.filters,state.filter_map.crt);
                        state.filter_map.crt.visible = 0;
                    }

                    //
                    if(obj.value=="blur"){
                        debuglog('adding blurfilter');
                        state.filter_map["blurfilter"] = new PIXI.filters.BlurFilter ();
                        state.filter_arr.push(state.filter_map["blurfilter"]);

                        stage.filters = state.filter_arr;
                        state.filter_map.blurfilter.enabled = false;
                    }

                    //
                    if(obj.value=="dream"){
                        //dreamfilterstart
                        if(!obj.textureimg) w("dream filter wasn't given a texture");
                        PIXI.Loader.shared.resources[obj.textureimg].texture.baseTexture.wrapMode = PIXI.WRAP_MODES.REPEAT;

                        var initobj = {
                            texture:PIXI.Loader.shared.resources[obj.textureimg].texture,
                            startFadeAmount:1,
                            endFadeAmount:0,

                        }
                        state.filter_map["dreamfilter"] = new DreamFilter(initobj);
                        state.filter_arr.push(state.filter_map["dreamfilter"]);

                        stage.filters = state.filter_arr;
                        state.filter_map.dreamfilter.enabled = false;
                        /*state.filter_map["dream"] = new DreamShader;

                        var l = stage.filters.length;
                        stage.filters = [state.filter_map.dream];
                        debuglog('adding dreamfilter');*/

                        //push isn't working...
                        //debuglog("pushing filter onto stage",stage.filters,state.filter_map.crt);
                        //state.filter_map.dream.visible = 0;

                    }

                    //
                    else if(obj.value=="tint"){
                        /*var spineData = loader.resources['spineBoy'].data;

                        //TINT_SLOT default value for new ones
                        spineData.findSlot('legSlot').data.color.b = 0.9;

                        var spine = new PIXI.spine.Spine(spineData);

                        //TINT_SPINE
                        spine.tint = 0xffdddd; //per model

                        //TINT_ATTACHMENT these two are the same, defined per ALL OBJECTS, default value was taken from above
                        spineData.findSlot('legSlot').attachment.color.g = 0.9;
                        spine.findSlot('legSlot').attachment.color.g = 0.9;

                        //TINT_SLOT slot of current object, USE IT vvvvv
                        spine.skeleton.findSlot('legSlot').color.g = 0.9;*/

                    }
                    debuglog('type filter',obj);

                    regexstr = v+":([^\n< ]*)";
                    updatefilters[v] = new RegExp(regexstr);
                }

                //
                else if(obj.type == "text"){
                    debuglog("textobj",obj);
                    var style = {
                        fontFamily : obj.font,
                        fontSize : obj.size,
                        fontStyle : obj.style,
                        fontWeight : obj.weight,
                        fill:'0x' + obj.fill,
                        stroke : '0x'+obj.stroke,
                        strokeThickness : obj.strokeThickness,
                        align: obj.align
                        /*dropShadow : obj.dropShadow,
                        dropShadowColor : '#'+obj.dropShadowColor,
                        dropShadowAngle : eval(obj.dropShadowAngle),
                        dropShadowDistance : obj.dropShadowDistance,
                        wordWrap : obj.wordWrap,
                        wordWrapWidth : obj.wordWrapWidth*/
                    };
                    /*var style = {
                        fontFamily : 'Arial',
                        fontSize : '18px',
                        fontStyle : 'normal',
                        fontWeight : 'bold',
                        fill : '#F7EDCA',
                        stroke : '#4a1850',
                        strokeThickness : 3,
                        dropShadow : true,
                        dropShadowColor : '#000000',
                        dropShadowAngle : Math.PI / 6,
                        dropShadowDistance : 6,
                        wordWrap : true,
                        wordWrapWidth : 785
                    };*/


                    /*if(v=="money"){
                        regexstr = "I have (\\$[^ <]*)";
                        updatetextpatterns[v] = new RegExp(regexstr);
                        obj.value = _inkStory.variablesState["money"] * 10;
                        obj.value = "Money: $"+obj.value;
                        obj.x = render_width - eval(obj.width);
                    }*/
                    regexstr = v+":\"([^\"]*)\"";
                    updatetextpatterns[v] = new RegExp(regexstr);
                    //n('here');
                    debuglog(updatetextpatterns,'textpatterns');

                    var cref = state[v+'_container'] = new PIXI.Container();
                    cref.position.x = 0;
                    cref.position.y = 0;
                    //cref.position.x = eval(obj.x);
                    //cref.position.y = eval(obj.y);

                    /*var gref = state[v+'_graphics'] = new PIXI.Graphics();
                    gref.beginFill(0x00FFFF, 0);
                    gref.drawRect(0, 0, eval(obj.width), eval(obj.height)+10);
                    gref.endFill();*/

                    var tref = state[v+'_text'] = new PIXI.Text(obj.value,style);
                    tref.visible=true;
                    tref.position.x = obj.x;
                    tref.position.y = obj.y;

                    state[v+'_textstyle'] = style;
                    //tref.style.fill = 0xFFFFFF;
                    //tref.position.x = (gref.width - tref.width)/2;
                    //tref.position.y = (gref.height - tref.height)/2;

                    //cref.addChild(gref);
                    cref.addChild(tref);
                    //cref.z=100;
                    //state[v+'_sprite'].z=zcount;
                    stage.addChild(cref);
                    tref.visible=true;

                }
                else {
                    //debuglog('unsuported anchor object type');
                }

                //debuglog(v,state[v]);
            }
        }
    } else {
        w("no pixivars or anchors found");
    }
    var watchvars =_inkStory.variablesState["watchvars"];
    $("#ui").css('height',render_height+'px');
    if(watchvars){
        watchvars = watchvars.replace(/ /g,"");
        watchvars_arr = watchvars.split(",");
        // vdump(watchvars_arr,'watchvars');
        for(var i in watchvars_arr){
            var entry = watchvars_arr[i];
            for(var k=1;k<20;k++){
                modentry = entry;
                if(_inkStory.variablesState["watchvar_"+entry+k]){
                    modentry = entry+k;
                }
                else if(k>1){
                    break;
                }
                //entry = watchvars_arr[i] + k;
                jsonstr = _inkStory.variablesState["watchvar_"+modentry];
                //obj = JSON5.parse("{"+jsonstr+"}");
                obj = parse_json(jsonstr);
                if(!obj.classes) obj.classes = '';
                obj.classes = obj.classes + ' ' + watchvar_classes;
                if(obj.orientation == 'vertical') obj.classes = obj.classes + ' vertical-bar';
                if(!obj.name) obj.name = '';
                if(modentry==entry) obj.k = 0;
                else obj.k = k;
                _inkStory.ObserveVariable(entry,uivar_update);
                var inkyvalue = _inkStory.variablesState[entry];

                if(obj.type=="text"){
                    uivar_text(entry,inkyvalue,obj);
                }
                else if(obj.type=="divbar"){
                    if(!obj.max) obj.max = 100;
                    if(!obj.bartext) obj.bartext = 'normal';
                    uivar_bar(entry,inkyvalue,obj);
                }
            }
        }
    }
    //Anote#14
    // deleted commented code for testing filters since they were moved to
    // their own file and that code was for a specific filter test we have
    // copies of that code in repository history if needed

    //debuglog('stage children',stage,stage.children);
    //debuglog('scene container children',scene_container.children);
    /*stage.addChild(scene_container);
    stage.addChild(port_container);
    stage.addChild(spine_container);
    stage.addChild(top_container);*/
    if(ancr_containers){
        for(var i in ancr_containers){
            var t = ancr_containers[i];
            stage.addChild(t);
        }
    }
    stage.children.sort(depthCompare);
    //show_children_order();
    //vdump(stage.children,'anchor zindex order');
    //debuglog('sprites',sprite_list);
    //do initial render to set widths/heights
    renderer.render(stage);
}
/*function update_ui_vars(name,value){
	var e = $(".inkyvar_"+name);
	var updatetype = e.attr('updatetype');
	var id = e.attr('id');
	if(updatetype=="statbar"){
		update_observed_statbar(id,value);
	}

}*/

//Anote#29
// called from prerungame after preloading is done which includes loading the
// assets in memory, setting up all the objects the reader needs to function
// as it expects them, and doing ajax calls to fetch users achievements and
// load their data objects
function rungame(){
    state.loaded = true;
    //hide("#loading");
    jQuery("#loading").css("display","none");
    visible("#gamewrap"); 	// show("#gamewrap");

    if(!use_pixi){
        n("PIXI disabled");
        $("#gamewrap #canvascontainer").css('display','none');
    } else {
        n("PIXI enabled");
        $("#gamewrap #canvascontainer").append(renderer.view);
        animate();
    }

    $(document).ready(function(){
        /*$("#story").niceScroll({
            disablemutationobserver:true,
            enableobserver:true,
            horizrailenabled: false,
            //rtlmode: "auto",
            //autohidemode:'hidden'
        });*/
        startstory();
    });
}

function animate() {
    requestAnimationFrame(animate);
    renderer.render(stage);
}

seenpcounts = new Set();
function optionstyle_convert(){
    if(optionstyle=="inline"){
        debuglog("appending to story pos3");
        $('#choices').appendTo("#story");
        $("#choices").removeClass('choicescontainer');
        $("#choices").addClass('inlinechoices');
    }
    else if(optionstyle=="box"){
        debuglog("appending to box");
        $('#choices').appendTo("#gamewrap");
        $("#choices").removeClass('inlinechoices');
        $("#choices").addClass('choicescontainer');
        $("#choices").removeClass(function(index,classes){
            var matches = classes.match(/\b_\S+/ig);
            return (matches) ? matches.join(' ') : '';
        });

    }
    optionstylepre = optionstyle;
}
function startstory(){
    debuglog("StartStory")
    $.ajax({
        url: "?getkey=1",
        context: document.body
    }).done(function(str) {
        uniqid=str;
    });

    if(hidelogin){
        hide("#loginwrap");
    }

    //debuglog('clicked');
    $("#stage").after(string_continue); // draw next\continue //debuglog('optionstyle',optionstyle);

    //show the continue button now that loading is done and the stage is shown
    setTimeout(function(){  $("#continue").removeClass("hidden"); }, 2000);

    $('#gamewrap').append("<div id='choices' class='closed'></div>"); //WHERE THE CHOICE BOX IS APPENDED

    //optionstyle="box";
    optionstyle_convert();

    // external save function
    $("#save").click(function(){
        savedJson = _inkStory.state.toJson();
        jsonobj = JSON.parse(savedJson);
        jsonobj.htmlstate = $("#story").html();
        //debuglog(jsonobj.htmlstate);
        savedJson = JSON.stringify(jsonobj);
        var dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(savedJson);
        var dlAnchorElem = document.getElementById('downloadAnchorElem');
        dlAnchorElem.setAttribute("href",     dataStr     );
        dlAnchorElem.setAttribute("download", "scene.json");
        dlAnchorElem.click();
        //debuglog(savedJson);
    });

    // Press Space
    $('body').keyup(function(key){
        if(key.keyCode == 32 && continuedisabled == false){
            //$(".continue").click();
            if(readerstyle == "old") stopset=false;
            n('run_if_old_reader called from space');
            run_if_old_reader();
            //debuglog("clicked continue using spacebar");
            //click_if_next();
        }
    });

    detect_compile();
    debuglog("#pcount",pcount);

    //contclick
    $("#continue").click(function(event){
        if (typeof hook_continue != "undefined") hook_continue();
        // debuglog("continue click"); // was missing semicolon
        // debuglog($('#choices').html());
        //debuglog('continue entered',skip);
        //debuglog($("#loginwrap").length,'loginwrap');
        stopset = false;
        numclicks++; // if(numclicks>1) hide("#tips");

        let now = new Date();
        if (now - clicktime < doubleClickTimer && !skip && !loadinggame) { n('double click prevention'); return;}
        if (($("#loginwrap").css('display') != "none" && !autocontinue) && $("#loginwrap").length!=0 && debugmode==0) { n('not logged in'); return };

        clicktime = now;

        if (clicklock && !skip) { n('mid action click prevention'); return;}
        evt_continue_start();

        continue_animation(animations.continue_active);

        skip      = false;
        clicklock = true;
        //debuglog('clicked');
        pnext = pcount + 1;
        var current = $("#story > p:nth-child("+pcount+")"),
            next = $("#story > p:nth-child("+pnext+")")
        //debuglog('current',current,'next',next);


        if(current.length==0 || next.length==0 || current.prop('nodeName')!='P' || next.prop('nodeName')!='P'){
            e('Cannot continue');
            //debuglog('error: ',current.length,next.length,current.prop('nodeName'));
        }
        else if ($(next).hasClass('choice')) {
            let element = document.getElementById("choices");
            element.className = element.className.replace(uichoice,"")
            debuglog("Next has class choice on node",pcount,'Object and html',$(next),$(next).html());
            if(readerstyle=="old"){
                if(seenpcounts.has(pcount)){
                    //throw new Error("We've seen this choice before");
                }
                seenpcounts.add(pcount);
            }
            //stopset=true;
            hide("#continue");
            //atx-change1
            //$("#choices").html("");  //clears content so it can be populated again cleanly
            //$(document).trigger("choices_picked");
            evt_choices_picked();
            // $("#choices").addClass(ui.choices_classes);
            //n("appending choices to story pos4");
            //$("#story .choice").appendTo("#choices");

            // add _choice_ classes from inky # method
            for( var i=0; i<customClasses.length; i++ ) $("#choices").addClass(customClasses[i]);

            $("#story .choice").appendTo("#choices");

            // ?? matches P! and .class from each
            $("#choices > p.choice > a").each(function(index){
                // n("Parsing Choice "+$(this).html());
                //vdump($(this).html(),"choices html");
                // Attach firs letter of each choice as class
                if ($(this).html().substring(0, 2) == "P_" || $(this).html().substring(0, 2) == "P!") {
                    $(this).closest('p').addClass('patreon');
                    vdump($(this).closest('p'));
                    // $(this).html( $(this).html().replace("P!","") ); //debuglog('p tag',$(this).html());
                }

                // Apply choice .xxx as .xxx
                let html = $(this).html(),
                    match  = html.match(/\.([^ ]+)/); //debuglog("matches",m);
                if(match && match[1]){
                    html = html.replace(match[0],""); //debuglog("start",html);
                    $(this).html(html);
                    $(this).closest('p').addClass(match[1]);
                }

                // Apply first word as .choice-xxx
                let str = $(this).text().split(' ')[0].toLowerCase();
                str = `choice-${str}`; //debuglog("str is",str);
                $(this).closest('p').addClass(str);

                let stagger = animations.choice_delay_stagger*index
                $(this.parentNode).css({
                    "-webkit-animation-delay":(stagger)+"ms",
                    "animation-delay":(stagger)+"ms"
                });
            });

            $("#choices > p.choice.patreon > a").mousedown(function(e) {
                if(!valid_user && valid_user != uniqid && !debugmode){
                    //alert("This is exclusive to logged in Patreon Supporters");
                    $("#loginwrap").fadeIn('fast',function(){});
                    e.preventDefault();
                    e.stopPropagation();
                    return false;
                }
            });

            shortcutkeys();
            if(optionstylepre != optionstyle) optionstyle_convert();
            if(textstyle == "inkyfadein" && optionstyle=="inline"){
                if (typeof hook_showchoices != "undefined") hook_showchoices();

                iterationcount += 1;

                let uichoicevalid = false
                let showtime = inkyfadein_duration * iterationcount - 10;
                uichoicevalid = uichoice.test($("#choices")[0].classList);

                // debuglog("UichoiceValue: ", uichoicevalid);
                if (uichoicevalid) showtime = 0;

                // debuglog("Fading in choices with inline reader",showtime);
                /*placeholder("#choices","#story > p:last","choiceholder");
                setTimeout(function() {
                    $("*#choiceholder").removeAttr("style").empty().addClass("clean-up hide");
                }, Math.max(0,showtime+(animations.choices_delay_intro*2)) );*/
                //third test
                //if(!state.skip_fadein)
                setTimeout(function(){
                    iterationcount = 0;
                    $("#choices").addClass(animations.choices_animation_intro);

                    // empty contents of holder and prep for cleanup
                    // $("#choiceholder").empty().css("background-color","");

                    visible("#choices");
                    swap("#choices","hidden","visible");
                    // $("#choices").addClass("inkyfadein");
                    // $("#choices").removeClass("preinkyfadein");
                    // $("#choices").addClass("inkyfadein");
                    choices_animate_onshow();
                    //$(document).trigger("choices_new_shown");
                    //n("updating scroll pos8");
                    //updatescroll();
                    evt_choices_new_shown();
                    //},Math.max(0, showtime+animations.choices_delay_intro ));
                },Math.max(0, showtime+animations.choices_delay_intro ));
                debuglog("Choice Delay ", showtime+animations.choices_delay_intro)
                /*else {
                    visible("#choices");
                    evt_choices_new_shown();
                }*/
            }
            else{
                visible("#choices");
                $("#choices").removeClass(animations.choices_animation_intro);
            }
            /*show("#choices p");
                state.choicevisible = true;*/

            state.choicevisible = true;

            $("#choices").addClass("preinkyfadein");
            $("#choices").removeClass("preinkyfadein");
            //??
            $("#choices").addClass("inkyfadein");

            choices_clickend();

            function choices_clickstart(){
                debuglog('clickstart');
                $("#choices").prepend("<div id='blockclicks'></div>");
                $("#choices").addClass("avoid-clicks");
                $("#choices p").addClass("disabled_choice");
                state.choicelock = true;
            }
            function choices_clickend(){
                $("#choices").removeClass(animations.choices_animation_intro);
                //kj$("#choices").addClass(animations.ChoiceBoxAnimationEnd); // Refers to nothing
                $("#choices").removeClass("avoid-clicks"); //$("#choices p a").off();
                $("#blockclicks").remove();
                state.choicelock = false;
                // debuglog("choiceclick add class "+animations.ChoiceBoxAnimationEnd);
                // $("#choices").addClass(animations.ChoiceBoxAnimationEnd).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
                // 	debuglog("choiceclick remove class "+animations.ChoiceBoxAnimationEnd);
                // 	$("#choices").removeClass(animations.ChoiceBoxAnimationEnd);
                // 	$("#blockclicks").remove();
                // 	state.choicelock = false;
                // });
            }


            //$("#choices").addClass(animations.choice_box_animationEnd);
            // $("#choices").removeClass("avoid-clicks"); //$("#choices p a").off();
            // $("#blockclicks").remove();
            // state.choicelock = false;


        }
        else {
            if(!continuedisabled) {
                // debuglog("Show Continue");
                // show("#continue");
            }

            // detect_compile();
            pcount = pnext;
            parsetext(next)
            // debuglog("#storyid>>>>>>#",storyid.size, "#pcount#", pcount)
            choicedelay = show_next(current,next)
            // n("Show next(core) "+choicedelay);
            // n("SHOW NEXT(CORE) "+show_next(current,next));
        }
        clicklock = false;

        if(state.firstclick) state.firstclick = false;

        if(readerstyle=='old' && linebyline){
            var curPos = $("#story").scrollTop();
            var pobj = $("#story .show").last().get(0);
            var toPos = pobj.offsetTop;
            debuglog("scrollto2: curpos",curPos,"toPos",toPos,"ele",$("#story .show").last().get(0));
            debuglog('scrolling',curPos,toPos,pobj);
            scrollToBottom(curPos,toPos);
        }

        if(optionstylepre != optionstyle) optionstyle_convert();
        n('run_if_old_reader called from click_if_next when there is a choice block');
        run_if_old_reader();
        //debuglog('choicestext',$("#choices").html());
        if(optionstyle=="inline" && newchoices){
            /*n('moving choices '+optionstyle);
                $("#choices").appendTo("#textbox");
                $("#choices").appendTo("#gamewrap");*/
            n("appending choices to story");
            $("#choices").appendTo("#story");
            newchoices=false;
            //debuglog('choices inline',$('#choices'),current);
        }
        evt_continue_end();
    });

    // detect_compile();
    current = $("#story > p:nth-child("+pcount+")");
    parsetext(current);
    newPs();

    n('run_if_old_reader called from startstory');
    run_if_old_reader();

    /*setTimeout(function(){
            $(".age-disclaimer").hide();
    },15000);*/
}

// placholdermaker
function placeholder(element,object,idname) {
    let emptyboxheight = 0,
        choicesvisible = $(element).hasClass("show")
    if (!choicesvisible) {
        show(element);
        emptyboxheight = $(element).outerHeight()
        hide(element);
    } else {
        emptyboxheight = $(element).outerHeight()
    }
    // n("Empty Box Height "+ emptyboxheight + " and choicevisible is " + choicesvisible)
    $(object).after(`<p id='${idname}' class='command' style='height:${emptyboxheight}px'>&nbsp</p>`)
    return;
}


/////////////////////////////////
// Prescripted JS logic called from Inky
/////////////////////////////////
function call_event(name,eobj){
    n('called event',name,eobj);
    switch(name){
        case "clear_stage":
            break;
        case "clear_scenes":
            //scene_container.removeChildren();
            break;
        case "clear_spine":
            //spine_container.removeChildren();
            break;
        case "clear_portraits":
            //port_container.removeChildren();
            //state['acontainer_portrait'].removeChildren();
            ports = state.acontainer_portrait.children;
            for(var i in ports){
                ports[i].visible = false;
            }
            break;
        case "clear_anchor":
            break;
        case "clear_anchors":
            break;
        case "set_clicksound":
            sound.click = eobj.file;
            if(!state.sound_cache[sound.click]){
                e(sound.click + " file is not a loaded sound file");
            }
            else {
                if(eobj.volume) state.sound_cache[sound.click].volume(sound.clickvol);
            }
            break;
        case "set_choice_clicksound":
            sound.choice = eobj.file;
            if(!state.sound_cache[sound.choice]){
                e(sound.choice + " file is not a loaded sound file");
            } else {
                if(eobj.volume) state.sound_cache[sound.choice].volume(sound.choicevol);
            }
            break;
        case "set_textstyle":
            textstyle = eobj.style;
            break;
        case "set_readerstyle":
            readerstyle = eobj.style;
            break;
        case "set_global_volume":
            break;
        case "global_mute":
            break;
        case "set_stage_bg":
            break;
        case "set_stage_bg":
            break;
        case "textbox_class":
            break;
        case "set_var":
            n('setting '+eobj.name+' to '+eobj.value);
            state[eobj.name] = eobj.value;
            window[eobj.name] = eobj.value;
            break;
        case "update_container_position":
            update_container_position(eobj);
            break;
    }
}

//////////////////////////////
// Custom HTML tag closing of text from inky based on requirements
//////////////////////////////
var selfclosedtags = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'menuitem', 'meta', 'param', 'source', 'track', 'wbr'];
String.prototype.replaceBetween = function(start, end, what) {
    return this.substring(0, start) + what + this.substring(end);
};

function fixhtml(str){
    evt_fixhtml_start();
    var regex = /(<([^>]+)>)/ig,
        temptext = str;
    while ((match = regex.exec(str)) != null) {
        token = match[0];
        if(token.substr(0,2)=="</"){
            temptext = temptext.replace(token, "");
        }
        //debuglog("initial match found at " + match.index,match);
    }
    var opentags = [];
    answertext = [];
    match = regex.exec(temptext);
    //debuglog('removed closing',temptext);
    while(match) {
        token = match[0];
        //debuglog("match found at ",match.index,match,opentags,temptext);
        if((idx = Number($.inArray(token,opentags))) !== -1){
            var splitstr = token.split(" ");
            trueidx = Number(idx);
            tagname = splitstr[0].replace("<","");
            tagname = tagname.replace(">","");
            // debuglog('working on tag',trueidx,opentags,opentags[trueidx]);
            // debuglog('working on','token',token);
            // debuglog('looking for tag name',token);
            // debuglog('found tag name',tagname);
            if(!$.inArray(tagname,selfclosedtags) !== -1){
                endtag="</"+tagname+">";
                temptext = temptext.replaceBetween(match.index, match.index + token.length,endtag);
                newlastIndex = match.index + endtag.length;
                regex.lastIndex = newlastIndex;
                opentags.splice(trueidx,1);
                //debuglog('replacing start at',match.index,'length',token.length,'temptxt',temptext,'textrange',temptext.slice(match.index,match.index+token.length),opentags,'on ',trueidx,opentags[trueidx]);
                //debuglog('result text',temptext);
                //debuglog('removed tag',trueidx,opentags);
            }
        }
        else {
            opentags.push(token);
        }
        //debuglog('doing regex',temptext,regex.lastIndex);
        match = regex.exec(temptext);
    }
    //debuglog('final temptext',temptext);
    var div = document.createElement('div');
    div.innerHTML=temptext;
    evt_fixhtml_end();
    return (div.innerHTML);
}

function parsetext_given(str){
    $("#gamebody").append("<div id='tempele' style='display:none'>"+str+"</div>");
    parse_text($("#tempele"));
    $("#tempele").remove();
}
////////////////////////////////////////////
//Parses a single P element's text from Inky
////////////////////////////////////////////
function parsetext(ele){
    if(!disable_fadein_check) state.skip_fadein = true;
    evt_parsetext_start(ele);
    var emptyP = false
    //console.log('checking bg',bgchange);
    autocontinue=updated_scene=updated_sceneoverlay=updated_scenemid=false;
    if(profiling) {
        t0 = performance.now();
    }

    if(typeof ele != "undefined"){
        origtext = ele.html();
        txt = ele.html();
        if(typeof txt !="undefined"){
            bgchange = new RegExp("\\bbg:([^ ]+)\\b");
            console.log('got txt',txt,ele,ele.html());
            if(txt.match(bgchange)){
                //console.log('bg change happened',txt);
                state.lastbgchange = txt;
            }
            else {//replay everything so we get actors and everything else up to the last bg change
                state.lastbgchange = state.lastbgchange + " " + txt;
            }
        }

        htmlfixed = fixhtml(origtext);
        //htmlfixed = origtext;
        ele.html(htmlfixed);
        //debuglog('htmlfixed',htmlfixed);\

        debuglog("ParsePre: ",origtext)
        debuglog("ParseHtml: ",htmlfixed)
        for(var k in recursive_replacepatterns){
            v = recursive_replacepatterns[k];
            text=ele.html();
            match = text.match(v[0]);
            if(match && match[0]){
                var temptext = text;
                var matches = [];
                var mfound = true;
                while(mfound){
                    match = temptext.match(v[0]);
                    temptext = temptext.replace(v[0],v[1]);
                    if(!match){
                        mfound=false;
                    }
                    else matches.push(match);
                }
                newtext = temptext;
                ele.html(newtext);
            }
        }

        /////////////////////////////////////
        // The Parser | replacepatterns
        /////////////////////////////////////
        for(var k in replacepatterns){
            var v = replacepatterns[k];
            var text, newtext;


            if(text.indexOf("<style") == -1){
                text = ele.html();
                text = $("<textarea/>").html(text).text();
                newtext = text.replace(v[0],v[1]);
                // newtext = newtext.replace(/\r?\n|\r/g,''); //remove returns
                ele.html(newtext)
                // ele.html = ele.html.replace(/\r?\n|\r/g, '');

            }
            else text = newtext = ele.html();

            if(k=="achievements"){
                match = text.match(v[0]);
                //debuglog('achievements match',v[0],match);
                if(match && match[1]){
                    a = match[1].trim();
                    //debuglog(match);
                    fullname = get_full_achievement_name(a);
                    if(!fullname){
                        w('achievement missing name');
                    }
                    else {
                        /*if(!check_achievement(a)){
                            //code_name = get_code_name(a);
                            //debuglog('code name found'+code_name);
                            $.when(add_achievement("&name="+fullname+"&code_name="+a+"&description=blank")).then(function(){
                                $.when(get_achievement_list()).then(function(){
                                    achievement_id = get_achievement_id(fullname);
                                    //n('adding user achievement',achievement_id,a);
                                    add_user_achievement(achievement_id);
                                });
                            });
                        }
                        else {
                            achievement_id = get_achievement_id(fullname);
                            add_user_achievement(achievement_id);
                        }*/
                    }
                }
            }
            else if(k=="howler"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    s = match[1];
                    var spath = s;
                    //sobj = JSON5.parse("{"+match[2]+"}");
                    sobj = parse_json(match[2]);
                    if(state.sound_cache[spath]){
                        if(sobj.loop) state.sound_cache[spath].loop(sobj.loop);
                        if(sobj.volume) state.sound_cache[spath].volume(sobj.volume);
                        eval('state.sound_cache[spath].'+sobj.action);
                    }
                    else {
                        w("could not load soundfile from cache "+spath);
                    }
                }
            }
            else if(k=="portrait_add"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    var name = match[1];
                    var file = match[2];
                    var x = Number(match[3]);
                    var y = Number(match[4]);
                    if(check_file(file)){
                        var v = 'portrait_'+name;
                        v = v.trim();
                        n('creating sprite "'+v+'_sprite'+'"');
                        if(!state[v]) state[v] = new PIXI.Graphics();
                        var resource = PIXI.Loader.shared.resources[file];
                        //debuglog('texture',file);
                        if(!state[v+'_sprite']){
                            state[v+'_sprite'] = new PIXI.Sprite(PIXI.Loader.shared.resources[file].texture);
                            sprite_list[v] = state[v+'_sprite'];
                            portrait_list[v] = state[v+'_sprite'];
                            state['acontainer_portrait'].addChild(state[v+'_sprite']);
                            //port_container.addChild(state[v+'_sprite']);
                        }
                        else {
                            state[v+'_sprite'].texture = PIXI.Loader.shared.resources[file].texture;
                        }
                        //debuglog('move rel',state[v+'_sprite'].width,state[v+'_sprite'].height,x,y);
                        state[v+'_sprite'].position.x = 0 - (Number(state[v+'_sprite'].width) / 2) + x;
                        state[v+'_sprite'].position.y = 0 - Number(state[v+'_sprite'].height) + y;
                        state[v+'_sprite'].centerme = false;
                        state[v+'_sprite'].visible=true;
                        //debuglog('sprite w/h',state[v+'_sprite'].width,state[v+'_sprite'].height,state[v+'_sprite'].position.x,state[v+'_sprite'].position.y);
                    }
                }

            }
            else if(k=="portrait_activeone"){
                match = text.match(v[0]);
                if(match && match[1]){
                    var temptext = text;
                    var matches = [];
                    var mfound = true;
                    while(mfound){
                        match = temptext.match(v[0]);
                        temptext = temptext.replace(v[0],"");
                        if(!match){
                            mfound=false;
                        }
                        else matches.push(match);
                    }
                    newtext = temptext;
                    ele.html(newtext);
                    for(var i in matches){
                        match = matches[i];
                        var name = match[1];

                        var v = 'portrait_'+name;
                        v = v.trim();
                        if(state[v]){
                            for(var k in portrait_list){
                                if(k != v) portrait_list[k].filters = [gray];
                                else portrait_list[k].filters = [];
                            }
                        }
                        else {
                            debuglog("portrait ",v,'does not exist');
                        }
                    }
                }

            }
            else if(k=="portrait_active"){
                match = text.match(v[0]);
                if(match && match[1]){
                    var temptext = text;
                    var matches = [];
                    var mfound = true;
                    while(mfound){
                        match = temptext.match(v[0]);
                        temptext = temptext.replace(v[0],"");
                        //debuglog('temptext',temptext);
                        if(!match){
                            mfound=false;
                        }
                        else matches.push(match);
                    }
                    newtext = temptext;
                    ele.html(newtext);
                    for(var i in matches){
                        match = matches[i];
                        var name = match[1];

                        var v = 'portrait_'+name;
                        v = v.trim();
                        if(state[v]){
                            portrait_list[v].filters = [];
                        }
                        else {
                            w("portrait ",v,'does not exist');
                        }
                    }
                }

            }
            else if(k=="portrait_unactive"){
                match = text.match(v[0]);
                if(match && match[1]){
                    var temptext = text;
                    var matches = [];
                    var mfound = true;
                    while(mfound){
                        match = temptext.match(v[0]);
                        temptext = temptext.replace(v[0],"");
                        if(!match){
                            mfound=false;
                        }
                        else matches.push(match);
                    }
                    newtext = temptext;
                    ele.html(newtext);
                    for(var i in matches){
                        match = matches[i];
                        var name = match[1];

                        var v = 'portrait_'+name;
                        v = v.trim();
                        if(state[v]){
                            portrait_list[v].filters = [gray];
                        }
                        else {
                            w("portrait ",v,'does not exist');
                        }
                    }
                }

            }
            else if(k=="portrait_dismiss"){
                match = text.match(v[0]);
                if(match && match[1]){
                    var temptext = text;
                    var matches = [];
                    var mfound = true;
                    while(mfound){
                        match = temptext.match(v[0]);
                        temptext = temptext.replace(v[0],"");
                        if(!match){
                            mfound=false;
                        }
                        else matches.push(match);
                    }
                    newtext = temptext;
                    ele.html(newtext);
                    for(var i in matches){
                        match = matches[i];
                        var name = match[1];

                        var v = 'portrait_'+name;
                        v = v.trim();
                        if(state[v]){
                            portrait_list[v].visible = false;
                        }
                        else {
                            w("portrait ",v,'does not exist');
                        }
                    }
                }
            }
            else if(k=="pause" && text.match(v[0]) != null){
                var match = text.match(v[0]);
                var delay = match[1].trim();

                debuglog("Pause",match)
                if (match && delay) {
                    emptyP = true;
                    n("updating scroll pos1");
                    updatescroll();
                    iterationcount = 0;
                    $(ele).addClass("command clean-up")

                    if (String(delay) == "stop" || Math.sign(delay) === 0 ) {
                        show("#continue");
                        evt_scripted_pausestop();

                    } else if (typeof Number(delay)  === "number") {
                        hide("#continue");
                        evt_scripted_pause();
                        setTimeout(function(){
                            evt_scripted_unpause();
                            show("#continue");
                        }, Math.abs(delay) );

                        debuglog("Pause Delay",delay)
                        if (Math.sign(delay) == -1) {
                            setTimeout(function() {
                                click_if_next();
                                evt_scripted_pause_negative();
                            }, Math.abs(delay) );
                        }
                    }
                }
            }
            else if(k=="call_event"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    estr = match[1];
                    splitstr = estr.split(':');
                    eventname = splitstr[0];
                    splitstr2 = estr.split('"');
                    eobj = {};
                    //if(splitstr[1]) eobj = JSON5.parse("{"+splitstr2[1]+"}");
                    if(splitstr[1]) eobj = parse_json(splitstr2[1]);
                    call_event(eventname,eobj);
                }
            }
            else if(k=="set_clicksound" || k=="set_choice_clicksound"){
                matches = text.match(v[0]);
                if(matches){
                    var soundfile = k,
                        tstr      = matches[1],
                        tsplit    = tstr.split(":"),
                        file      = tsplit[0],
                        volume    = tsplit[1];

                    if(!state.sound_cache[file]) {
                        e(file + " " + errormessage.setsound);
                        sound.click = sound.default;
                    } else {
                        sound.click = file;
                        if (k=="set_clicksound") state.sound_cache[sound.click].volume(sound.clickvol);
                        if (k=="set_choice_clicksound") state.sound_cache[sound.choice].volume(sound.choicevol);
                    }

                }
            }
            else if(k=="set_var"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    estr = match[1];
                    splitstr = estr.split(':');
                    varname = splitstr[0];
                    varvalue = splitstr[1];
                    state[varname] = varvalue;
                    window[varname] = varvalue;
                    n('set '+varname+' to '+varvalue);
                }
            }
            else if(k=="textbox_class"){
                matches = multi_match(text,v[0],ele);
                //debuglog('textbox_class',matches,text,v[0],k);
                for(var i in matches){
                    match = matches[i];
                    estr = match[1];
                    splitstr = estr.split(':');
                    varvalue = splitstr[0];
                    debuglog('textbox class',splitstr,varvalue);
                    $("#textbox").removeClass();
                    $("#textbox").addClass(varvalue);
                }
            }
            else if(k=="clear"){
                matches = multi_match(text,v[0],ele);

                for(var i in matches){
                    match = matches[i];
                    cval = match[1].trim();
                    n("clearing",v[0],match);
                    n('clear matches',matches,match);
                    n('clearing '+cval);
                    vdump(ancr_containers,"clear anchors");
                    if(cval == "screen"){
                        //Clear anchors
                        for(var i in ancr_containers){
                            var ac = ancr_containers[i].children;
                            debuglog('clear ac children',ac);
                            for(var k in ac){
                                ac[k].visible = false;
                            }
                        }
                    }

                    else if(cval == "textnow") {
                        $("#story p.parsed.show").addClass("clean-up clear-text");
                        $("#story p.parsed.show.clear-text").addClass("hide");
                        $("#story p.parsed.show.clear-text").removeClass("show")
                    }
                        //second test
                    //else if(cval == "text" && !state.skip_fadein) {
                    else if(cval == "text") {
                        iterationcount = 0;
                        if(skip_first_clear_animate){
                            $("#story > p.parsed.clear-text").addClass("hide").removeClass("show");
                            skip_first_clear_animate=false;
                        }
                        else {
                            $("#story p.parsed.show").addClass("clean-up clear-text");
                            $("#story p.parsed.show").addClass(animations.clear_screen_nodes);
                            if(animations.clear_screen_nodes) $("#story > p.parsed.clear-text").addClass(animations.clear_screen_nodes);
                            $("#story").addClass(animations.clear_screen_story);
                            //$("#story").getNiceScroll().hide();//hide scrollbar when we do animations
                            setTimeout(function() {
                                $("#story > p.parsed.clear-text").addClass("hide").removeClass("show");
                                if(animations.clear_screen_nodes) $("#story > p.parsed.clear-text").removeClass(animations.clear_screen_nodes);
                                $("#story").removeClass(animations.clear_screen_story);
                                /*setTimeout(function(){
                                    //$("#story").getNiceScroll().show();
                                    $("#story").getNiceScroll()[0].lazyResize(30);
                                },200);*/
                                //$("#story").getNiceScroll()[0].init({enableobserver:true});//hide scrollbar when we do animations
                            }, animations.clear_screen_delay);

                        }
                    }
                    /*else if(cval == "text") {
                        iterationcount = 0;
                        $("#story p.parsed.show").addClass("clean-up clear-text");
                        $("#story p.parsed.show").addClass(animations.clear_screen_nodes);
                        $("#story").addClass(animations.clear_screen_story).addClass("animated");
                        $("#story > p.parsed.clear-text").addClass("hide");
                        $("#story > p.parsed.clear-text").removeClass("show")
                        $("#story > p.parsed.clear-text").removeClass(animations.clear_screen_nodes);
                        $("#story").removeClass(animations.clear_screen_story);
                    }*/
                }
            }
            else if(k=="save"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    savename = match[1];
                    n('saving game '+savename);
                    save_game(savename);
                }
            }
            else if(k=="saveto"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    savename = match[1];
                    stemp = savename.split(":");
                    n('saving game '+stemp[0]);
                    save_game(stemp[0]);
                }
                /*matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    debuglog('in saveto',matches,text);
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    temp = match[1];
                    tsplit = match[1].split(":");
                    savename = tsplit[0];
                    spath = tsplit[1];
                    debuglog('matches split',match[1],tsplit)
                    debuglog('saving game to',savename,spath);
                    save_to(savename,spath);
                }*/
            }
            /*else if(k=="update_ui"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    json = match[1];
                    obj = JSON5.parse("{"+json+"}");
                    update_ui(obj);
                }
            }*/
            else if(k=="icall"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    match = matches[i];
                    json = match[1];
                    //obj = JSON5.parse("{"+json+"}");
                    obj = parse_json(json);
                    icall(obj);
                }
            }
            else if(k=="refresh_ui"){
                var regex = v[0];
                if(text.search(regex) >= 0){
                    text = text.replace(regex,'');
                    n("refreshing ui");
                    refresh_ui();
                }
            }
            /*else if(k=="rflag"){
                var regex = v[0];
                if(text.search(regex) >= 0){
                    text = text.replace(regex,'');
                    n("updating registry flags");
                    update_rflags();
                }
            }*/
            else if(k=="unlock_achievement"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    achievementname = match[1];
                    n("updating achievement "+achievementname);
                    unlock_achievement(achievementname);
                }
            }
            else if(k=="lock_achievement"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    achievementname = match[1];
                    n("updating achievement "+achievementname);
                    lock_achievement(achievementname);
                }
            }
            else if(k=="sync_watchvars"){
                var regex = v[0];
                if(text.search(regex) >= 0){
                    text = text.replace(regex,'');
                }
            }
            else if(k=="load"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    savename = match[1];
                    n('loading game '+savename);
                    load_game(savename);
                }
            }
            else if(k=="loadraw"){
                matches = multi_match(text,v[0],ele);
                for(var i in matches){
                    //n("clear was called");
                    match = matches[i];
                    //debuglog("clearing",v[0],match);
                    //debuglog('clear matches',matches,match);
                    savename = match[1];
                    n('loading game raw '+savename);
                    load_game_raw(savename);
                }
            }
        }
        for(var k in updatepatterns){
            v = updatepatterns[k];
            text=ele.html();
            //text.replace(/<\/div>/," </div>");
            //debuglog('text',text);
            matches = multi_match(text,v,ele);
            for(var i in matches){
                match = matches[i];
                if(match && match[1]){
                    imgstr = match[1].replace(/^\s+|\s+$/,"");
                    //debuglog('propstr',match[1],match);
                    //imgstr = match[1].replace(/<\/div>/,"");
                    imgstr = imgstr.trim();
                    var isspine = check_spine(imgstr);
                    //debuglog('imgstr is',imgstr);

                    if(imgstr == "clear"){
                        var sprite = state[k+'_sprite'];
                        if(state[k+'_sprite']) state[k+'_sprite'].visible = false;
                        if(state['spine_'+k]) state['spine_'+k].visible = false;
                    }

                    else {
                        //var tsplit = imgstr.split(":");
                        //debuglog('imgstr spine check',isspine);
                        debuglog("image/spine",k,imgstr)
                        if(isspine){
                            update_spine(k,imgstr);
                        }
                        else{
                            update_img_sprite(k,imgstr);
                        }
                    }
                }
            }
        }
        // This is used for dispalying Text in the PIXI canvas itself
        // Anote#37
        /* for(var k in updatetextpatterns){
             v = updatetextpatterns[k];
             text=ele.html();
             text = $("<textarea/>").html(text).text();
             match = text.match(v);
             if(match && match[1]){
                 debuglog('text checking',text,match,k,state[k+'_text']);
                 tref = state[k+'_text'];
                 cref = state[k+'_container'];
                 sref = state[k+'_textstyle'];
                 tref.text = match[1];
                 tref.visible=true;
                 cref.visible=true;

                 //debuglog('align',cref.width,sref.align);
                 if(sref.align == "right"){
                     //debuglog('align right',sref.align,'width',tref.width,tref.height);
                     tref.position.x = render_width - tref.width - 10;
                     //tref.position.y = tref.height;
                 }

                 debuglog('updatetextpatterns '+k,v,state[k+'_text'],text,match);
             }
             newtext = text.replace(v,"");
             ele.html(newtext);
         }*/

        for(var k in updatefilters){
            v = updatefilters[k];
            text=ele.html();
            //debuglog('text',text);
            matches = multi_match(text,v,ele);
            for(var i in matches){
                match = matches[i];
                if(match && match[1]){
                    debuglog('update filter',match[1],k,v);
                    var eobj = split_objstr(match[1]);
                    //debuglog('eobj',eobj);
                    if(eobj.value == 1){
                        debuglog('setting filter ',k,'to',match[1]);
                        //stage.filters = [state.filter_map[k]];
                        state.filter_map[k].enabled=true;
                        if(eobj.json && k=='dreamfilter'){
                            if($.isNumeric(eobj.json.startFadeAmount)) state.filter_map[k].uniforms.fadeAmount=eobj.json.startFadeAmount;
                            if($.isNumeric(eobj.json.endFadeAmount)) state.filter_map[k].endFadeAmount=eobj.json.endFadeAmount;
                            if($.isNumeric(eobj.json.additionalAberration)) state.filter_map[k].uniforms.additionalAberration=eobj.json.additionalAberration;
                            if($.isNumeric(eobj.json.squiggleAlpha)) state.filter_map[k].uniforms.squiggleAlpha=eobj.json.squiggleAlpha;
                            if($.isNumeric(eobj.json.distortionAmount)) state.filter_map[k].uniforms.distortionAmount=eobj.json.distortionAmount;
                            if($.isArray(eobj.json.squiggleColor))  state.filter_map[k].uniforms.squiggleColor = new Float32Array(eobj.json.squiggleColor);
                            if(eobj.json.fadeBlack == 1)  state.filter_map[k].fadeBlack = true;
                            else state.filter_map[k].fadeBlack = false;
                            if(isset(eobj.json.fadeMult)){
                                state.filter_map[k].fadeMult = eobj.json.fadeMult;
                            }
                            if(isset(eobj.json.fadeBlackMult)){
                                state.filter_map[k].fadeBlackMult = eobj.json.fadeBlackMult;
                            }
                            //else this.uniforms.squiggleColor = new Float32Array([1.0, 0.0, 1.0]);
                            //debuglog("squiggleColor",state.filter_map[k].uniforms.squiggleColor);
                        }
                    }
                    else {
                        state.filter_map[k].enabled=false;
                    }
                    /*state['acontainer_'+k].visible = (match[1] == 'true');
                    state[k+'_graphics'].visible = (match[1] == 'true');
                    n('setting visible to true');*/
                    //state['overlay_graphics'].visible = true;
                }
            }
        }
    } else {
        w('undefined ele html',ele,ele.html());
    }

    debuglog("ParsePost: ",text)

    // Set as parsed
    //parsed(ele);
    $(ele).removeClass("unparsed");
    $(ele).addClass("parsed");
    $(ele).html($(ele).html().trim());
    if($(ele).html()){
        state.skip_fadein = false;
    }
    //$(ele).addClass('trimmed');

    // error logging
    if(profiling){
        t1 = performance.now();
        td = t1 - t0;
        debuglog("%cparsetext took "+td+"ms on element",'background: MediumOrchid; color: black',ele.get(0));
        profile_arr.push({time:td,text:origtext});
    }

    evt_parsetext_end(ele);
    return emptyP;
}
function parse_json(str){
    if(str[0]!="{") str = "{" + str + "}";
    try {
        return JSON5.parse(str);
    }
    catch(err) {
        w("could not parse json "+str);
        console.trace();
        return {};
    }
}


///////////////////////////////
// Reader functions for the purpose of code reusability
///////////////////////////////
function refresh(ele,add,remove) {
    $(ele).addClass(add);
    $(ele).removeClass(remove);
}
function swap(ele,remove,add) {
    $(ele).removeClass(remove);
    $(ele).addClass(add);
}
function hide(ele){
    $(ele).removeClass("show");
    $(ele).addClass("hide");
}
function show(ele){
    $(ele).removeClass("hide");
    $(ele).addClass("show");
}
function visible(ele){
    $(ele).removeClass("hidden");
    $(ele).addClass("visible");
}
function vhidden(ele){
    $(ele).removeClass("visible");
    $(ele).addClass("hidden");
}
/*function parsed(ele){
	$(ele).removeClass("unparsed");
	$(ele).addClass("parsed");
}*/
function playsound(soundref) {
    if(!sound_loaded) return;
    try {
        state.sound_cache[soundref].play();
        state.sound_cache[sound.choice].volume(sound.choicevol)
        evt_playsound(soundref);
    }
    catch (err){
        //throw error( soundref + " IS NOT LOADED SOUND FILE"	);
        w(soundref + " is not loaded sound file");
    }
    // } else { e(soundref+ " IS NOT LOADED SOUND FILE") }
};

///////////////////////////////
// if there is a next P node from inky and we continued, we have to parse the
// next P and show the parsed results.
///////////////////////////////
var iterationcount = 0;
function show_next(current,next){
    if(readerstyle=="default"){
        //debuglog('current is',current,'next is ',next);
        hide(current);
        show(next);
    }
    //debuglog("forcefade is",textstyle_forcefade,current,next);
    //debuglog('textstyle',textstyle,textstyle_forcefade);
    if(textstyle=='fadein' || textstyle_forcefade){
        next.addClass("prefadeintext");
        //debuglog('set prefadein');
        setTimeout(function(){
            //debuglog('set fadein');
            next.removeClass("prefadeintext");
            next.addClass("fadeintext");
        },fadein_duration);

    } else if(textstyle == "inkyfadein") {
        debuglog("Inkyfadein ",next.get(0))
        iterationcount++;
        //first test
        if(!state.skip_fadein){//skip nodes that had no text, only had commands and were just parsed
            //if(true)
            next.addClass("preinkyfadein");

            var set_animation, set_timeout, set_fadestagger;
            for(i in animations.node_reveal_target){
                if (next.is(`p${i},p:has(${i})`)) {
                    let [stagger,timeout,animation] = animations.node_reveal_target[i]
                    set_animation = animation;
                    set_timeout   = timeout;
                    set_stagger	  = stagger;
                    if (stagger < 0) set_stagger = inkyfadein_duration;
                    break;
                } else {
                    set_animation = animations.node_reveal;
                    set_timeout   = animations.node_timeout;
                    set_stagger	  = inkyfadein_duration;
                }
            }

            debuglog("!!!animated",set_stagger,set_timeout,set_animation)

            setTimeout(function(){
                next.removeClass("preinkyfadein");
                next.addClass("inkyfadein").addClass(set_animation);
                setTimeout(function(){
                    next.removeClass(set_animation);
                },set_stagger+set_timeout);
            },set_stagger*iterationcount);
        }
        else {
        }

    } else if(readerstyle=='default'){
        $('.typewriter').removeClass("typewriter");
        //current.attr('id',"");
        $('#typedtext').attr('id','');
        next.addClass("typewriter");
        //next.find('div').attr('id',"typedtext");
        //typewriter();
    };
    //Anote#38
    // You hardcoded this as inline, meaning even if settings.js isn't setting
    // the read mode to inline the choices box will be set as if it was
    // settings.js

    if(optionstylepre != optionstyle) optionstyle_convert();
    if(optionstyle=='inline'){
        //n("appending choices to story pos2");
        //$("#choices").appendTo("#story");
    }
    if(textstyle=="typewriter" && !textstyle_forcefade){
        if($(".typewriter div") && $(".typewriter div").html()){
            ttext = $(".typewriter div").html().trim();
            $(".typewriter div").attr('id','typedtext');
            typewriterstart(ttext,1);
        }
    } else {
        textstyle_forcefade = false;
        //n('textstyle forcefade used up');
    };
    if(!state.firstclick && readerstyle=="default"){
        //debuglog('playing click');
        if(sound_loaded) state.sound_cache[sound.click].play();
    };

    //Anote#37
    // I really don't like show_next is returning a math value, show_next is
    // logic for showing the next P tag.  It returning anything doesn't make
    // sense unless you do it for the purpose of error handling and then it'd
    // return true on success and false on failure but that's also not needed
    // it just shouldn't return anything.this could easily just be passed to a
    // state based variable in the reader or global variable and actually both
    // are available wherever you call this function.
    return inkyfadein_duration*iterationcount
}



// debuglog("Event1 ", this);
// debuglog("Event2 ", $("a[code]").attr("code"));
// debuglog("Event3 ", $("a[code]"));
// debuglog("newps", )
// debuglog("newps", event[0].getAttribute("code"))
// $("p:has(.imgdisplay)
// choice_animation(animations.choice_chosen,event.target);
// choices_animation(animations.choices_animation_intro);
// choice_animation(animations.choice_chosen,"#choices");
// $("#choices").addClass(animations.choices_animation_outro);

// placeholder("#choices","#story > p:last","choiceholder_outro");
function choice_click(event) {
    if(state.choicelock) { n("choiceclick cancel"); return; }
    evt_choice_click_start(event);

    playsound(sound.choice);

    state.choicelock = true;
    event.preventDefault();


    $("#choices").prepend("<div id='blockclicks'></div>");
    $("#choices").addClass("avoid-clicks");

    // Applies animations for buttons choices
    let codeselect = this.getAttribute("code")
    $("#choices > p").removeAttr("style");
    $("#choices > p").removeClass(animations.choice_animation_intro)
    $(`#choices > p:has(a[code=${codeselect}])`).addClass(animations.choice_chosen);
    $(`#choices > p:has(a[code!=${codeselect}])`).addClass(animations.choice_notchosen)
    //detect_compile();

    debuglog('CHOICECLICK');
    setTimeout(function(){
        newPs();
        let pnext = pcount + 1;
        let current = $("#story > p:nth-child("+pcount+")");
        let	next = $("#story > p:nth-child("+pnext+")");
        if(next.length == 0) {
            e("No next node when next node expected")
        } else {
            pcount = pnext;
            debuglog("@NEXT",next);
            parsetext(next);
            show_next(current,next);
        }
        lastscrollstop = scrollstop = pcount;// = storyid.size
        run_if_old_reader();
    }, animations.choices_delay_outro);

    // placeholder("#choices","#story > p:last","choiceholder_outro");
    // setTimeout(() => {
    // 	$("*#choiceholder_outro").removeAttr("style").empty().addClass("clean-up").css("display","none");
    // }, animations.choices_delay_outro*5);

    evt_choice_click_end(event);
}

function detect_compile() {
    // debuglog( "SHIT",$(`#story > p:nth-child(${pcount})`) )
    // debuglog( "SHIT",$(`#story > p:nth-child(${newcount})`) )
    // debuglog( "SHIT",$(`#story > p:nth-child(${newcount})`).next() )
    // debuglog('SHIT',_inkStory.currentTags);
    // debuglog('SHIT',_inkStory.canContinue);
    // debuglog('SHIT',_inkStory.CleanOutputWhitespace);
    // var listItem = $( "#bar" );
    // alert( "Index: " + $( "li" ).index( listItem ) );

    // let counter = pcount-1
    // let temp0 = $(`#story > p[class^='storyID']:eq(${counter})`).get(0)
    // let temp1 = $(`#story > p[class^='storyID-${storyid.size}']`).get(0)
    // let temp2 = $(`#story > p`).index( $(`[class^='storyID-${storyid.size}']`) )
    // let temp3a= $(`#story > p:not(.choice)`).last().get(0)
    // let temp4a= $(`#story > p:eq(${temp3})`).get(0)
    // let temp4 = $(`#story > p:eq(${temp3})`).index()
    // let temp5a= $(`#story > p`).last().get(0)
    // let temp5 = $(`#story > p`).last().index()

    // debuglog("%pcount",pcount)
    // if (storyid.get(pcount)!=undefined)
    // {
    // 	debuglog("%t0",temp0)
    //  	// debuglog("%",storyid.get(pcount).element)
    // }
    // debuglog("@storysize", storyid.size)
    // debuglog("@t1",temp1, " Placed at ",temp2)
    // debuglog("@t3",temp3a," Placed at ",temp3)
    // debuglog("@t4",temp4a," Placed at ",temp4)
    // debuglog("@t5",temp5a," Placed at ",temp5)
    // var element = $("p[name^='objectid:']");
    // var elementClass = element.attr('class');

    // let pcheck = $("#story > p.XXX").eq(-2)
    // debuglog("@checkfrom:",checkfrom, " : ", $("#story > p.XXX").eq(-2).index())
    // debuglog("@pcount:", pcount)
    // const checkstart = $("#story > p.XXX").eq(-2)
    $(`#story > p[class^='storyID-${storyid.size}']`).addClass("XXX")
    var cancompile = false
    let checkstart = $("#story > p.XXX").eq(-2)
    if (checkstart.length == '') checkstart = $("#story > p").eq(0)
    // let checkfrom      = checkstart.get(0)
    // let checkfromvalue = checkstart.index()
    // debuglog("!!!checkstart",checkstart)
    // let temp3 = $(`#story > p:not(.choice)`).last().index()
    let temp3 = $(`#story > p:not(.choice)`).last().next().index()
    const nodeclass = [];
    //&& checkstart.index() > 0
    if (checkstart.length != 0 && pcount > checkstart.index() ) {
        debuglog("!!checkstart",checkstart)
        debuglog("!!if",pcount , checkstart.index())
        // debuglog("@Previous XXX>",checkfrom," :",checkstart.index())
        let localpcount = checkstart.index();
        for (var i = localpcount+1; i < temp3; i++) {
            const entrynode  = $(`#story > p:eq(${i})`).get(0)
            const entrynodefilter = $(entrynode).filter("p[class^='storyID']");

            let storyIDNumeric;
            let storyIDClass = entrynodefilter.attr('class');
            if (storyIDClass != undefined) {
                storyIDClass = storyIDClass.split(" ");
                storyIDClass.forEach( (value, i) => {
                    const storystring = "storyID-"
                    if (value.indexOf(storystring) > -1 ) {
                        storyIDNumeric = Number( value.slice(storystring.length) );
                    }
                })
                // nodeset.push(storyid.get(storyIDClass).element);
                // debuglog("@PCOUNT:", $(entrynode).index());
                // debuglog("#StoryID:", storyid.get(storyIDNumeric).element);
                // debuglog("#StoryTAGS:", storyid.get(storyIDNumeric).tags);

                nodeclass.push(storyid.get(storyIDNumeric).class);

                let trackindex;
                let foundchunk = false;

                const chunk = "compile"
                storyid.get(storyIDNumeric).tags.forEach( (value, i, array) => {
                    debuglog("#array",array)
                    if (value === chunk) {

                        cancompile = true;
                        foundchunk = true;
                        nodeclass.forEach( function (value, i) {
                            // debuglog("@foreach", value)
                            // debuglog("@foreach", $(`#story > p.${value}`))
                            let prepvalue = $(`#story > p.${value}`)
                            parsetext($(`#story > p.${value}`))
                        })
                    }
                })

                if (foundchunk) {
                    trackindex = nodeclass.length;
                    debuglog("#chunkcount",trackindex)

                    pcount = checkstart.index()+trackindex;
                }

            }
        }
    }

    // debuglog("@Nodeset",nodeset)
    // debuglog("@NodeClass",nodeclass)
    if (!cancompile) {
    }
}



function choice_animation(x,ele) {
    // debuglog('choice_animation',x,ele);
    // n("choice animation");
    $choice=$(ele).closest("p");
    savedclasses =  $choice.attr('class');
    $choice.removeClass().addClass(x + ' ' + savedclasses).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        $(this).removeClass();
        $(this).attr("class",savedclasses);
    });
};
function choices_animation(x) {
    debuglog('choice_box_animation',x);
    $("#choices").addClass(x).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        debuglog('removing class',x);
        $("#choices").removeClass(x);
    });
    /*savedclasses =  $choice.attr('class');
    $choice.removeClass().addClass(x).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        debuglog('removing class',x);
        $(this).removeClass(x);
        $(this).attr("class",savedclasses);
    });*/
};
//continue button animations
function continue_animation(element) {
    $('#continue #outteranimate').removeClass().addClass(element).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        $(this).removeClass();
        evt_continue_button_animate_end();
        //$(this).addClass('');
    });
};


//////////////////////////////////
// New Content
//////////////////////////////////
function newPs(){
    var iterationcount = 0;
    //hide("#choices");
    //atx-edit2
    vhidden("#choices");
    state.choicevisible = false;
    //$("#story > p").addClass("unparsed");
    if ( readerstyle=="default" ) show("#story > p:nth-child("+pcount+")");
    //if(optionstylepre != optionstyle) optionstyle_convert();
    if ( optionstyle=="inline" ) {
        $("#choices").html("");
        place_choice("inline");
    }
    $(".choice > a").click(choice_click);
    choices_animate_onshow();
    if(typeof hook_newPs != "undefined") hook_newPs();
}
// if ( continuedisabled === false ) {
// 	setTimeout(function(){ if (continuedisabled) show("#continue"); }, 1000);
// }
function choices_animate_onshow(){
    debuglog("INTRO ANIMATION")
    swap("#choices>p.choice",animations.choice_animation_intro,animations.choice_animation_intro)
    //possibly add a tick/page sound here so people know when it's enabled
}

function place_choice(loc) {
    if(optionstyle==loc){
        n("appending choices pos1");
        $("#choices").appendTo("#story");
    }
    else {
        n("choices inplace");
    }
}

function run_if_old_reader() {
    if ( readerstyle=="old" ) {
        //$('.continue').click();
        if ( linebyline ){
            n('run_if_old_reader calling click_if_next with settimeout');
            setTimeout("click_if_next()", linebylinedelay);
        } else {
            n('run_if_old_reader calling click_if_next');
            click_if_next();
        }
    }
}



///////////////////////////////////////
// Listeners
///////////////////////////////////////
//Anote#7
// uniqid is filled with a unique string using the ajax call to ?getkey
// this string is part of the patreon login API and is used to verify the user is authenticated in the session
// clicklock is to make sure that while we are mid parsing that someone doesn't click continue multiple times
// as this could cause all sorts of unintended behavior
// clicktime is used for profiling/measuring the speed of execution
// numclicks is just a simple counter
var uniqid    = '',
    clicklock = false,
    clicktime = null,
    numclicks = 1
function fire_click(node){
    if (document.createEvent) {
        var evt = document.createEvent('MouseEvents');
        evt.initEvent('click', true, true);
        ret = node.dispatchEvent(evt);
    } else if (document.createEventObject) {
        // triggerMouseEvent (node, "mousedown");
        node.fireEvent('onclick') ;
    } else if (typeof node.onclick == 'function') {
        node.onclick.apply(node);
    }
}


// Height Listener
function onElementHeightChange(elm, callback){
// Could only find this script to detect on scale change. Seems bulky
    var lastHeight = elm.clientHeight, newHeight;
    (function run(){
        newHeight = elm.clientHeight;
        if( lastHeight != newHeight ) callback();
        lastHeight = newHeight;
        if( elm.onElementHeightChangeTimer ) clearTimeout(elm.onElementHeightChangeTimer);
        elm.onElementHeightChangeTimer = setTimeout(run, 100);
    }) ();
}
onElementHeightChange(document.getElementById("story"), function(){
    jumpshortcut()
});

// Scroll Listener
$("#story").on({
    scroll:function() {
        clearTimeout($.data(this, 'scrollTimer'));
        //$("#story").getNiceScroll()[0].lazyResize(30);
        $.data(this, 'scrollTimer', setTimeout(function() {
            jumpshortcut()
            //scrollstop = scrollhistory(pcount,scrollstop,lastscrollstop);
            // if (newscrollstop<scrollstop) scrollstop = lastscrollstop;
            // if (newscrollstop>scrollstop) scrollstop = scrollhistory(pcount,scrollstop);
        }, animations.continue_listen_cycle));
    },
});

var callback = function(allmutations) {
        allmutations.map( function(mr) {
            //    let $story = $("#story")
            // if ($story.get(0).scrollHeight > $story.height()) $story.css('padding-left','8px');
            // else $story.css('padding-left','0');
            clearTimeout($.data(this, 'scrollTimer'));
            $.data(this, 'scrollTimer', setTimeout(function() {
                // jumpshortcut()
                // onlastscrollstop = scrollstop;
                // let newscrollstop = scrollhistory(pcount,onlastscrollstop);
                // if (newscrollstop<scrollstop) scrollstop = lastscrollstop;
                // if (newscrollstop>scrollstop) scrollstop = scrollhistory(pcount,scrollstop,lastscrollstop);
            }, animations.continue_listenkl_cycle));
        });
    },
    mo = new MutationObserver(callback),
    options = {
        'attributes': true,
        'childList' : true
    }
article = document.querySelector('#story');
mo.observe(article, options);


// Keypress 1,2,3,4...
$(document).keydown(function(e){
    //let choicesvisible =  $("#choices").isInViewport("#textbox",false);
    //debuglog("!!!! choices visible", choicesvisible)
    if(e.keyCode > 48 && e.keyCode <= 57 && state.enable_shortcuts){
        //debuglog(e.keyCode,keynum,e.keyCode -48);
        var val = e.keyCode - 48;
        //debuglog('val',val,$('[code=' + val + ']'));
        var ele = $('[code=' + val + ']').get(0);
        debuglog('keydown code',ele);
        if(typeof ele != 'undefined'){
            evt_choice_keydown(e.keyCode);
            //debuglog('ele',ele);
            if($(ele).closest("p").hasClass("patreon") && !valid_user && valid_user!=uniqid && debugmode == 0){
                $("#loginwrap").fadeIn('fast',function(){});
                //e.preventDefault();
                //e.stopPropagation();
                //return false;
            } else {
                /*$("#choices > p.choice > a").each(function(){
                    $(this).removeAttr('code');
                    debuglog('removing attr code',this);
                });*/
                fire_click(ele);
            }
        }
        else w('keydown ele not found');
    }
});
// label choices with their shortcut key number
function shortcutkeys(){
    let keynum = 1;
    $("#choices > p.choice > a").each(function(){
        //this line was really messed up and giving bad classnames and key attributes
        $(this).html('<div class="choicenum choice_' + keynum + '">' + keynum + '</div> ' + $(this).html());		//debuglog('assigning code',keynum, $(this));
        $(this).attr('code',keynum);		//debuglog('code is',$(this).attr('code'));
        keynum++;
    });
}

lastpcount = 0;
function click_if_next(){
    tcount = pcount+1;
    tnext = $("#story > p:nth-child("+tcount+")");
    // debuglog('click_if_next called',tnext);
    //debuglog('current',current.get(0),'pcount',pcount);
    //debuglog('current tags',_inkStory.currentTags);
    //debuglog('nextnode',tnext,tnext.html());
    if(lastnext==tnext){
        n("Going next from same source node more than once");
    }
    //debuglog('pause clickifnext',stopset);
    lastnext=tnext;
    //check if there's a next node, and that we're allowed to go to it at this time
    if(tnext.length>0 && !stopset && !continuedisabled){
        if(readerstyle=="old" || debugmode==1){
            skip = true;
        }
        // continue_animation(animations.continue_active);
        //debuglog('continue animation');
        $('#continue').click();
    } else if(stopset){
        n("Not proceeding, as pause:stop was called");
        n("updating scroll pos3");
        updatescroll();
        //console.trace();
        stopset=false;
    } else if(!state.choicelock){
        n("Tried to progress when theres no more story yet, showing choices");
        n("updating scroll pos4");
        updatescroll();
    }
}


/////////////////////////////////////////////////
// Scrolling Sub Functions
/////////////////////////////////////////////////
function updatescroll () {
    if (!scrolling) {
        w("UPDATESCROLL " + scrollstop)
        lastscrollstop = scrollstop;
        scrollTo(scrollstop);
        //scrollstop = scrollhistory(pcount,lastscrollstop,lastscrollstop);
    }
}

/*function scrollhistory(pnum,pstart,plast=0) {
	let tnum         = Math.max(1,pnum-1);
	let	breakpoint   = tnum;
	let	hnum         = pstart;
	let	hnumvisible  = 0;

	// var ele     = $("#story > p:nth-child("+hnum+")");
	// let toPos   = scrollHeight(ele,"#story");
	// let curPos  = $("#story").scrollTop(); // debuglog("scrollto: curpos",ele.get(0).offsetTop,"toPos", toPos);
	// let readTop = ele.get(0).offsetTop + (ele.get(0).offsetHeight * scroll_historyteaser); // variable defining the top stopping position

	while(hnum < breakpoint){
		inode = $("#story > p:nth-child("+hnum+")");
		if ($(inode).isInViewport("#textbox",true)) {
			hnumvisible++;
		} ;
		hnum++;
	};

	hnumvisible-- // I hate doing this but I can't figure out where the minuse 1  comming from
	// if (hnumvisible == -1) hnumvisible = 1

	let pstop = pstart
	if (hnumvisible < 1) {
		// FIXME and make consistent without this special case
		// let lasthistory = $("#story .lasthistory")
		// if (lasthistory.length != 0)
		pstop = plast //lasthistory.index();
		// if (lasthistory.length != 0) pstop = lasthistory.index();
	} else pstop = Math.min(Math.abs(hnumvisible)+pstart,pnum);
	debuglog("!!!!updatescroll:" ,pstart,hnumvisible,pnum," > ",pstop)
	return pstop
	// {dCodes : dCodes, dCodes2 : dCodes2};//(hnumvisible+pstart);
	// return Math.min((hnumvisible+pstart),pnum);	// {dCodes : dCodes, dCodes2 : dCodes2};//(hnumvisible+pstart);
}*/

var lastinview = null;
var firstinview = null;
var last_lastinview = null;//keeps track of if we've seen this element last time so we always advance if possible

function calc_scrollstop(pnum,pstart,plast=0) {
    lastinview = null;
    firstinview = null;
    nodenum = pnum - 1;

    pnodes = $("#story > p.parsed:gt("+pnum+")");

    if(pnodes.length == 0){
        lastinview = $("#story > p:nth-child("+pnum+")");
        if(!checkInView(lastinview,true)){
            w("setting scrollstop to current given element pnum "+pnum+" despite it not being in view");
        }
        pstop = pnum;
    }
    else {
        $(pnodes).each(function(){
            var ele = $(this).get(0);
            if(checkInView(ele,true)){
                if(firstinview == null) firstinview = ele;
                lastinview = ele;//keep cursor of the last in view
                console.log('in view',lastinview);
            }
            else if(firstinview != null) {
                return false;//breaks each, so we stop the loop after we found the last one
            }
        });
        pstop = $(lastinview).index() + 1;
    }
    //convert the element to the child number, calcs based on siblings

    //check if we used this last time, if we did, increment by 1 if an element exists to support it
    if(pstop == last_lastinview){
        var trystop = pstop+1;
        var tryele = $("#story > p:nth-child("+trystop+")");
        if(tryele.length > 0){
            pstop = trystop;
        }
    }
    /*var pele = $("#story > p:nth-child("+pstop+")");
    var pstartele = $("#story > p:nth-child("+pnum+")");
    if(last_lastinview != null) var lele = $("#story > p:nth-child("+last_lastinview+")");
    else var lele = null;
    console.log('pstop',pstop,'pele',pele,'pstart',pnum,'pstartele',pstartele);//'laststop',last_lastinview,'laststop ele',lele);*/
    //update our memory of where we last scrolled to
    last_lastinview = pstop;
    return pstop;
}
function checkInView(elem,partial) {
    var container = $("#story");
    var contHeight = container.height();
    var contTop = container.scrollTop();
    var contBottom = contTop + contHeight ;

    var elemTop = $(elem).offset().top - container.offset().top;
    var elemBottom = elemTop + $(elem).height();

    var isTotal = (elemTop >= 0 && elemBottom <=contHeight);
    var isPart = ((elemTop < 0 && elemBottom > 0 ) || (elemTop > 0 && elemTop <= container.height())) && partial ;

    return  isTotal  || isPart ;
}

/////////////////////////////////
// Update reader's spine object by name with properties parsed from inky
/////////////////////////////////
function update_spine(spinename,propstr){
    vdump(spinename,propstr+' calling update_spine with');
    spinestr = propstr.replace(/^\s+|\s+$/,"");
    spinestr = spinestr.trim();
    debuglog('spinestr',spinestr);
    parts = spinestr.split(":");
    cutstr = parts[0] + ":" + parts[1] + ":";
    jsonstr = spinestr.replace(cutstr,"");
    jsonstr = jsonstr.slice(1, -1);
    debuglog('spine jsonstr',jsonstr);
    //spineobj = state[spinename+'_spineprops'];
    spineobj = {};
    spineobj.file = parts[0];
    spineobj.animation = parts[1];
    spineobj.visible = true;
    if(jsonstr){
        //var tobj = JSON5.parse("{"+jsonstr+"}");
        var tobj = parse_json(jsonstr);
        Object.assign(spineobj,tobj);
        vdump(tobj,'tobj');
    }
    debuglog('spine container',state['acontainer_'+spinename]);
    if(!spineobj.center){
        if(state['acontainer_'+spinename].centerme){
            spineobj.center = state['acontainer_'+spinename].centerme;
        }
    }
    if(!spineobj.centery){
        if(state['acontainer_'+spinename].centermey){
            spineobj.centery = state['acontainer_'+spinename].centermey;
        }
    }
    if($.isNumeric(spineobj.cx)){
        state['acontainer_'+spinename].x = spineobj.cx;
    }
    if($.isNumeric(spineobj.cy)){
        state['acontainer_'+spinename].y = spineobj.cy;
    }
    if(!spineobj.x){
        spineobj.x = 0;
    }
    if(!spineobj.y){
        spineobj.y = 0;
    }
    /*if(!spineobj.x){
        if(state['acontainer_'+spinename].offsetx){
            spineobj.x = state['acontainer_'+spinename].offsetx;
        }
        else spineobj.x = 0;
    }
    if(!spineobj.y){
        if(state['acontainer_'+spinename].offsety){
            spineobj.y = state['acontainer_'+spinename].offsety;
        }
        else spineobj.y = 0;
    }*/
    n('setting spine with '+spinename);
    vdump(spineobj,'spineobj');
    //debuglog('spineobj',spineobj);
    spineset(spinename,spineobj);
}
function update_container_position(obj){
    state['acontainer_'+obj.name].x = obj.x;
    state['acontainer_'+obj.name].y = obj.y;
}

function spineset(name,spineobj){
    debuglog('spineset',spineobj);
    //name,file,x,y,scale,animation,visible
    //debuglog('spinefile',spineobj.file);
    if(!check_spine_file(spineobj.file)) return false;
    var firstobj = false;
    if(typeof state['spine_'+name] == "undefined"){
        firstobj = true;
    }
    else {
        //state['acontainer_'+name].removeChild(state['spine_'+name]);
        //scene_container.removeChild(state['spine_'+name]);
    }
    state['acontainer_'+name].removeChild(state['spine_'+name]);
    state['spine_'+name] = new PIXI.spine.Spine(PIXI.Loader.shared.resources[spineobj.file].spineData);
    //if(firstobj){
    /*if(spineobj.ztop) top_container.addChild(state['spine_'+name]);
    else scene_container.addChild(state['spine_'+name]);*/
    //debuglog(scene_container.children);
    //}
    state['acontainer_'+name].addChild(state['spine_'+name]);
    var spineref = state['spine_'+name];

    spineref.visible = true;
    if(spineobj.visible) spineref.visible = spineobj.visible;
    // set the position
    //debuglog('spineref dim',render_width,spineref.width);
    if(spineobj.center){
        //spineref.position.x = (render_width/2) + spineobj.x;
        spineref.position.x = (render_width - spineref.width) / 2 + state['acontainer_'+name].offsetx + (spineref.width/2);
        //spineref.position.x = Math.abs(render_width/2 - spineref.width / 2) + Math.abs(render_width - spineref.width);
        //debuglog(name,'spineref centerx',spineref.position.x);
    }
    else if(spineobj.x) spineref.position.x = spineobj.x;

    if(spineobj.centery){
        //spineref.position.y = (render_height/2) + spineobj.y;
        spineref.position.y = (render_height - spineref.height) / 2 + state['acontainer_'+name].offsety + (spineref.height/2);
        //spineref.position.y = (render_height - spineref.height) / 2;
        //spineref.position.y = Math.abs(render_height/2 - spineref.height / 2) + Math.abs(render_height - spineref.height);
        //debuglog(name,'spineref centery',spineref.position,spineref.width,spineref.height,'container pos and dims',state['acontainer_'+name].position,state['acontainer_'+name].width,state['acontainer_'+name].height);
    }
    else if(spineobj.y) spineref.position.y = spineobj.y;
    /*if(spineobj.x) spineref.position.x = spineobj.x;
    if(spineobj.y) spineref.position.y = spineobj.y;*/

    container_stats(name);

    if(spineobj.scale) spineref.scale.set(spineobj.scale);
    if(typeof spineobj.loop == "undefined") spineobj.loop = true;
    if(spineobj.timescale) spineref.state.timeScale = spineobj.timescale;
    if(spineobj.tint){
        spineobj.tint = String(spineobj.tint);
        spineref.tint = spineobj.tint;
        debuglog("tinting",spineref.tint,spineobj.tint);
        //spineref.tint = '0xff0000';
    }
    else {
        debuglog("no tint for ",name);
    }

    // set up the mixes!
    /*spinetest.stateData.setMixByName('piebj', 0.2);
    spinetest.stateData.setMixByName('jump', 'walk', 0.4);

	debuglog('spineset',spineref,spineobj);
	reset any animation states
	spineref.state.clearTracks();
	spineref.skeleton.setToSetupPose()*/

    // set animation
    if(spineobj.animation) spineref.state.setAnimation(0, spineobj.animation, spineobj.loop);
}

///////////////////////////////////
// Update reader's PIXI sprite by name with properties parsed from inky
///////////////////////////////////
function update_img_sprite(spritename,propstr){
    n('update sprite',spritename);
    tstr = propstr.replace(/^\s+|\s+$/,"");
    tstr = tstr.trim();
    objsplit = tstr.split('"');
    parts = objsplit[0].split(":");
    img = parts[0];
    if($.inArray(spritename, anchors_reset) !== -1){
        for(var i in anchors_reset){
            var v = anchors_reset[i];
            //debuglog('setting visible false for',v);
            state[v+'_sprite'].visible = false;
        }
    }
    var sprite = state[spritename+'_sprite'];
    var ancr = state['acontainer_'+spritename];
    sprite.visible=true;

    tobj = {};
    if(parts[1] && parts[2]){
        sprite.position.x = parts[1];
        sprite.position.y = parts[2];
    }
    //debuglog('"'+img+'"');
    if(typeof PIXI.Loader.shared.resources[img] == "undefined"){
        w("trying to render image that wasn't in the loader",img);
        vdump(PIXI.Loader.shared.resources,'loader');
        vdump(PIXI.Loader.shared.resources[img],'loader');
        return;
    }
    //debuglog('looking for',spritename,img);
    var texture = PIXI.Texture.from(img);
    sprite.texture = texture;
    //debuglog('smid pos',sprite.position.x,'width',texture.baseTexture.realWidth,'render width',render_width);
    ancr.visible = sprite.visible = true;
    n('pre center',ancr,sprite);
    if(ancr.centerme){
        //debuglog('centering sprite',spritename,PIXI.Loader.shared.resources[img].texture.baseTexture.width);
        sprite.position.x = (render_width - PIXI.Loader.shared.resources[img].texture.baseTexture.width) / 2 + ancr.offsetx;
        //sprite.position.y = 0;
    }
    if(ancr.centermey){
        sprite.position.y = (render_height - PIXI.Loader.shared.resources[img].texture.baseTexture.height) / 2 + ancr.offsety;
    }
    texture.update();
    //updated_bg = true;
    //autocontinue = true;
    //state[spritename+'_sprite']=sprite;
}

///////////////////////////////////
// Getters/setters for the _inkStory object
///////////////////////////////////
function setStory(s) {
    _inkStory = s;
    _inkStory.BindExternalFunctionGeneral("toggle_textbox", function (args) {
        if (args == true) {
            $("#expandtextbox").click();
        }
    });
    _inkStory.BindExternalFunctionGeneral("toggle_ui", function (args) {
        if (args == true) $("#ui").addClass("hide");
        else $("#ui").removeClass("hide");

    });
    load_registry();
    //debuglog('inkstory',_inkStory);
}

//deprecated function
// function ink_vars(name,value){
// 	window[name] = value;
// 	// debuglog('ink_vars',name,value);
// }

//Anote#11
// how to set or get ink vars isn't always consistent, it uses javascript
// proxies but only in some browsers and even with or without proxies there's
// different ways to do it.  Plus the $ function it uses is really unintuitive
// and can be confused for the jquery $ function, so I wanted to isolate this
// from confusion and for compatibility
function setInkVar(k,v){
    _inkStory.variablesState.$(k, v);
}
function getInkVar(k){
    return _inkStory.variablesState.$(k);
}

//inky calls any function with single param as an object
function icall(obj){
    if(typeof window[obj.call] !== 'undefined'){
        window[obj.call](obj);
    }
    else w("tried to icall function which doesn't exist "+obj.call);
}
function update_ui(obj){
    //verify object has properties we need
    if(!obj.id){
        w("update_ui didn't have the properties to make the call");
        return;
    }
    ele = $("#"+obj.id);
    for(i in obj['attr']){
        attr = obj['attr'][i];
        n('updating attribute',i,attr);
        ele.attr(i,attr);
    }
    for(i in obj['jquery']){
        param = obj['jquery'][i];
        ele[i](param);
    }
}

function healthbar_animation(curHealth,id) {
    maxHealth = $("#"+id).attr("max");
    barname = $("#"+id).attr("barname");
    var a = curHealth / maxHealth * 100;
    addclass= '';
    if(curHealth > maxHealth){
        a = 100;
        //addclass= " overmax";
        $("#"+id+" .curhealth").addClass('overmax');
    }
    else {
        $("#"+id+" .curhealth").removeClass('overmax');
    }
    $("#"+id+" .maxhealth").html(maxHealth);
    $("#"+id+" .curhealth").html(curHealth);
    $("#"+id+" .percent").html(a);
    $("#"+id+" .barname").html(barname);
    /*nametxt = '';
    if(barname.length > 0) {
        nametxt = "<span class='barname'>"+barname+"</span>";
    }
    if($("#"+id+" .health-bar-text .percent").length > 0) $("#"+id+" .health-bar-text .percent").html(Math.round(a) + "%");
    else $("#"+id+" .health-bar-text").html(nametxt + "<span class='curhealth"+addclass+"'>"+curHealth + " </span> / <span class='maxhealth'>" + maxHealth + "</span>");*/
    $("#"+id+" .health-bar-red").animate({
        'width': a + "%"
    }, 700);
    $("#"+id+" .health-bar").animate({
        'width': a + "%"
    }, 500);
    $("#"+id+" .health-bar-blue").animate({
        'width': a + "%"
    }, 300);
    $("#"+id+" .healthbar-total").html(curHealth + "/" + maxHealth);
}

function uivar_bar(name,value,obj){
    // n('updating observered var '+name+ ' '+value);
    var corename = name;
    if(obj.k>0) name = name + obj.k;

    if(value){
        $(".health-bar-red, .health-bar").stop();
    }
    curval = value;
    if(curval < 0) curval = 0;
    if(!obj.max){
        obj.max = 100;
    }

    statcont = $("#ui #statwrap_"+name);
    statdiv = $("#ui #stat_"+name);
    if(statcont.length==0 || statdiv.length==0){
        /*var ostr = '<div id="statwrap_'+name+'" class="'+obj.classes+'" update="uivar_bar_update" corename="'+corename+'" numname="'+name+'" max='+obj.max+' curval="'+value+'" bartext="'+obj.bartext+'" barname="'+obj.name+'"><div id="stat_'+name+'" class="health-box">'
            + '<div class="health-bar-red"></div>'
            + '<div class="health-bar-blue"></div>'
            + '<div class="health-bar"></div>'
            + '<div class="health-bar-text"></div>'
            + '</div></div>';
        $("#ui").append(ostr);*/
        w("could not find ui template for "+name);
        return;
    }
    else {
        $("#statwrap_"+name).attr('max',obj.max);
        $("#statwrap_"+name).attr('barname',obj.name);
    }
    uivar_update(corename,curval);
    //healthbar_animation(curval,"statwrap_"+name);

    if (typeof hook_observevar!="undefined") hook_observevar(name,value);
}

function uivar_text(name,value,obj){
    // n('updating observered var '+name+ ' '+value);
    var corename = name;
    if(obj.k>0) name = name + obj.k;
    if(!obj.name) obj.name = '';

    if (isNaN(value)) {
        value = Object.keys(_inkStory.variablesState["gameTime"]._keys) + ''
        value = value.split(".")
        value = value[1]
    }

    var statcont = $("#stat_"+name);
    /*if(statcont.length==1){
        if(window['stathookvalue_'+name]) value = window['stathookvalue_'+name](value);
        $("#statname_"+name).html(name);
        $("#statvalue_"+name).html(value);
    } else {*/
    statcont = $("#ui #statwrap_"+name);
    //var istr = '<div id="statdef_'+name+'" class="'+ classes +'" update="update_observed_stat"><span id="statdefname_'+name+'" class="capitalize">'+name+'</span> <span id="statdefvalue_'+name+'">'+value+'</span> </div>';
    if(statcont.length==0){
        /*var ostr = '<div id="statwrap_'+name+'" class="'+ obj.classes +'" corename="'+corename+'" numname="'+name+'" update="uivar_text_update" objname="'+obj.name+'"><div id="stat_'+name+'"></div></div>';
        $("#ui").append(ostr);*/
        w("could not find template for "+ name);
        return;
    }
    else {
        $("#statwrap_"+name).attr('objname',obj.name);
        $("#statwrap_"+name).attr('corename',corename);
        //$("#statwrap_"+name).attr('numname',name);
    }
    /*var istr = '<span id="statname_'+name+'" class="statname">'+objname+'</span> <span id="statvalue_'+name+'" class="statvalue">'+value+'</span>';
    $("#ui #stat_"+name).html(istr);*/
    uivar_update(corename,value);
    //}
    if (typeof hook_observevar!="undefined") hook_observevar(name,value);
}

function uivar_update(name,value){
    $("div[corename="+name+"][update=uivar_bar_update]").each(function(k,ele){
        id = $(ele).attr('id');
        healthbar_animation(value,id);
    });
    $("div[corename="+name+"][update=uivar_text_update]").each(function(k,ele){
        id = $(ele).attr('id');
        objname = $(ele).attr('objname');
        //numname = $(ele).attr('numname');
        /*var istr = '<span id="statname_'+name+'" class="statname">'+objname+'</span> <span id="statvalue_'+name+'" class="statvalue">'+value+'</span>';
        $("#ui #stat_"+numname).html(istr);*/
        $(ele).find(".statname").html(objname);
        $(ele).find(".statvalue").html(value);
    });
}
function refresh_ui(){
    for(i in watchvars_arr){
        v = watchvars_arr[i];
        value = _inkStory.variablesState[v];
        uivar_update(v,value);
    }
}

////////////////////////////////
// Text and motion handling
////////////////////////////////

// more jump
function jumpshortcut() {
    // debuglog("Current Scroll Position:",$("#story").scrollTop(),"/",$("#story").height() + $("#stage").offset().top +$("#story").scrollTop(),"/",$("#story")[0].scrollHeight);
    var scroll_trueheight   = $("#story")[0].scrollHeight
    var scroll_trueposition = $("#story").height() + $("#stage").offset().top +$("#story").scrollTop()
    if (scroll_trueposition < scroll_trueheight - 5) {
        if (!continuedisabled) {
            show("#continue");
            //swap("#more","hide","jump");
        }
        // prevent jump from displaying once jumped to the bottom
    } else if (!state.choicevisible) {
        //if (lastscrollstop != pcount) swap("#more","hide","jump");
        // hide("#continue");
        // swap("#more","jump","hide");
    } else {
        hide("#continue");
        //swap("#more","jump","hide");
    }

    if (stopset) hide("#continue");
};
$("#more").click(function() {
    w("Click " + scrollstop)
    scrollTo(pcount);
    lastscrollstop = scrollstop = pcount;
});

////////////////////////////
// scrolling
////////////////////////////
var lasttop        = 999999,
    lasttopeqcount = 0,
    scrollstop     = 1,
    lastscrollstop = 1,
    lastnext       = 1,
    scrolling      = false

/*function scrollTo(pnum){
    return false;
}*/
function scrollTo(pnum){
    //console.trace();
    n("SCROLLTO " + scrollstop )
    if($("#story > p:nth-child("+scrollstop+")").length == 0){
        //console.log("Scrollstop needs updated");
        scrollstop = calc_scrollstop(pcount,lastscrollstop,lastscrollstop);
        //n("SCROLLUPDATED2 " + scrollstop );
        pnum = scrollstop;
    }
    // if (isMobile) return;

    let scrollpos        = $("#story").scrollTop();
    let	scrollheight     = $("#story").height() + $("#stage").offset().top + scrollpos; // current location
    let	scrollheightmax  = $("#story")[0].scrollHeight; // scroll height
    scrollheight     = Math.abs(scrollheight-scrollheightmax);

    // debuglog ("scroll height",scrollheight,"scroll tolerance",scroll_tolerance,"scroll pos",scrollpos,"scroll height max",scrollheightmax);
    let tnum         = Math.max(1,pnum-1);
    let	baseanchor   = tnum;
    let	lasthistory  = tnum+0;
    let	bookmark 	 = tnum+1;
    let	breakpoint   = tnum+1;
    let	hnum         = 0;
    let	markhistory  = false;

    if (scrollheight > scroll_tolerance && pnum < pcount ) markhistory = true
    // debuglog("hnum",pnum,"Pcount",pcount, "Markhistory", markhistory);

    while(hnum < breakpoint){
        if (markhistory) {
            inode = $("#story > p:nth-child("+hnum+")");
            inode.addClass("history");
            // debuglog(inode.get(0))
        }
        hnum++;
    }

    if (markhistory) {
        check_empty(`#story > p:nth-child(${lasthistory})`,"lasthistory")
        check_empty(`#story > p:nth-child(${breakpoint})`,"breakpoint")
        check_empty(`#story > p:nth-child(${bookmark})`,"bookmark")

        function check_empty(node,name) {
            if ($(node).is(".command") || $(node).is(":empty") && $(node).next($(node)).is("p")) {
                check_empty( $(node).next() , name);
            } else if ($(node).length && $(node).is("p")) {
                $(`*#story>p.${name}`).removeClass(name)
                $(node).addClass(name);
            } else return;
        }
    }


    if (hnum>1) hnum -= 1;

    console.log('using hnum',hnum);
    var ele     = $("#story > p:nth-child("+hnum+")");
    let toPos   = scrollHeight(ele,"#story");
    let curPos  = $("#story").scrollTop(); // debuglog("scrollto: curpos",ele.get(0).offsetTop,"toPos", toPos);
    let readTop = ele.get(0).offsetTop + (ele.get(0).offsetHeight * scroll_historyteaser); // variable defining the top stopping position

    // calculate inverse // ?? turn into script
    let distance = toPos-curPos;
    let scale = (($("#stage").height() + $("#stage").offset().top))
    if( distance>=1) {
        let inverse = scale / distance;
        var chase = 1*inverse*inverse - 2*inverse;
        chase *= scroll_chasefactor;
        chase = Math.min(chase, scroll_duration_min);
    };

    debuglog("curpos,topos,ele",curPos, toPos,ele)
    if(readTop < toPos) toPos = readTop - scroll_padding;

    if (scrollheight > 10) { // Scroll as usual
        scrolling = true;
        setTimeout(scrollease("story",toPos,scroll_ease,scroll_duration - chase), scroll_delay); // Apply animation
        setTimeout(function(){
            n("SCROLLEND"); // Wait for the scrolling to stop then check to see what is visible
            scrolling = false;
            scrollstop = calc_scrollstop(pcount,lastscrollstop,lastscrollstop);
        },scroll_duration - chase - scroll_wait + scroll_delay);
    }
    else if (scrollheight > 5) scrollease("story",toPos,scroll_ease,(scroll_duration - chase)*.01)
};


$.fn.isInViewport = function(scrollwindow,strict) {
    if(!state.loaded){
        return false;
    }
    if (this == undefined) return
    let elementTop     = $(this).offset().top
    let elementHeight  = $(this).outerHeight() // (this).outerHeight(),
    let elementBottom  = elementTop + elementHeight // (this).outerHeight(),
    let viewportLeft   = $(scrollwindow).offset().left
    let viewportWidth  = $(scrollwindow).width()
    let viewportTop    = $(scrollwindow).scrollTop() + $(scrollwindow).offset().top
    let viewportHeight = $(scrollwindow).height()
    let viewportBottom = viewportTop + viewportHeight

    let elementRect    = $(this)[0].getBoundingClientRect();
    let windowRect     = $(scrollwindow)[0].getBoundingClientRect();
    let localScale     = ""
    //if (isMobile != undefined && isMobile) localScale = isMobileScale.split(",",1);



    let strictHeight = 0;
    let mobileOffset = 0;
    if (strict) strictHeight = elementHeight;
    //if (isMobile != undefined && isMobile) mobileOffset = elementRect.top - ( (elementRect.top*localScale)-elementRect.top );
    let validate = elementRect.bottom+strictHeight > viewportTop && (elementRect.top-mobileOffset)+strictHeight < viewportBottom;
    // if (strict) elementTop += (this).outerHeight();
    // if (strict) elementBottom += (this).outerHeight();
    // let validate = elementBottom > viewportTop && elementTop < viewportBottom


    if (false) {
        $(".debugsquare").remove()
        $("body").append(`<div class='debugsquare' style='color:black;background-color: #55881133; pointer-events: none; position:fixed; border: orange solid 1px;
								left:${elementRect.left}px;
								width:${elementRect.width}px; 
								top:${elementRect.top  - ((elementRect.top*localScale)-elementRect.top) }px;
								height:${elementRect.height}px;
							'>
							<br>${this.text()}
							<br>Element Top ${elementRect.top} 
							<br>Element New ${(elementRect.top*localScale)-elementRect.top} 
							<br>${Math.round(elementBottom)} > ${Math.round(viewportTop)} && ${Math.round(elementTop)} < ${Math.round(viewportBottom)}
							</div>`)

        $("body").append(`<div class='debugsquare' style='color:black; pointer-events: none; position:fixed; border: red solid 1px;
								left:${viewportLeft}px;
								width:${viewportWidth}px; 
								top:${viewportTop}px;
								height:${viewportHeight}px;
							'>
								`+
            // <br>Left: ${viewportLeft} | Width: ${viewportWidth}
            // <br>Top: ${viewportTop} | Height: ${viewportHeight}
            `
							</div>`)

        $("body").append(`<div class='debugsquare' style='color:black; background-color: #1144bb33; pointer-events: none; position:fixed; border: blue solid 1px;
								left:${viewportLeft}px;
								width:${viewportWidth}px; 
								top:${elementTop}px;
								height:${elementHeight}px;
							'>
							<br>${this.text()}
							<br>${Math.round(elementBottom)} > ${Math.round(viewportTop)} && ${Math.round(elementTop)} < ${Math.round(viewportBottom)}
							</div>`)

        //   $(scrollwindow).scrollTop() + ( ($(scrollwindow)[0].scrollHeight - this.get(0).offsetTop ) - ($(scrollwindow).height() + $(scrollwindow).offset().top - $(this).offset().top) )
        //    - ($(scrollwindow).height() + $(scrollwindow).offset().top - $(this).offset().top)
        //       let targetBottom     = $("#story")[0].scrollHeight
        //       let scrollElementTop = this.get(0).offsetTop
        //       let scrollPosition   = $("#story").scrollTop()
        // let scrollHeight	 = $("#story").height()
        // let scrollTop		 = $("#story").offset().top - elementTop
        // let scrollDistance   = targetBottom - scrollElementTop
        // $("#story").prepend(`<div class='debugsquare' style='position:relative;top:0px;'><div style='color:black; background-color: #11bb4433; pointer-events: none; border: green solid 1px; position:absolute; z-index: 10000;
        // 						width:${viewportWidth}px;
        // 						top:${scrollPosition}px;
        // 						height:${(targetBottom - scrollElementTop) - (scrollHeight + scrollTop)}px;
        // 					'><center>-------------------------------<center>
        // 						ScrollTop : ${$("#story").offset().top} <br>
        // 						${this.get(0).offsetTop} | ${elementTop}
        // 					</div></div>`)

    }

    return validate;//elementBottom > viewportTop && elementTop < viewportBottom;
}

function scrollHeight (ele,view){ // SUPER IMPORTANT MATH // Needs Review
    // position: relative;
    // top: 2092px;
    // z-index: 1;

    // let elementTop     = $(ele).offset().top
    // let elementBottom  = elementTop + (ele).height() // (this).outerHeight(),
    // let viewportLeft   = $(view).offset().left
    // let viewportWidth  = $(view).width()
    // let viewportTop    = $(view).scrollTop() + $(view).offset().top
    // let viewportBottom = viewportTop + $(view).height() - elementTop

    // setTimeout(function() { $(".debugsquare").detach() },100000);

    // let scroll1 = $(view).scrollTop();
    // let	scroll2 = $(view)[0].scrollHeight - ele.get(0).offsetTop;
    // let	scroll3 = $(view).height() + $(view).offset().top - $(ele).offset().top;

    // w("element " +elementTop+ " | " +elementBottom+ " | " +viewportTop+ " | " +viewportBottom )
    // w("scroll " +scroll1+ " + " +scroll2+ " - " +scroll3);//+ " | " +scroll4 );
    // w("return " +Math.floor($(view).scrollTop() + ( ($(view)[0].scrollHeight - ele.get(0).offsetTop ) - ($(view).height() + $(view).offset().top - $(ele).offset().top) )))

    console.log('scrollheight thing',ele,ele.get(0));
    return Math.floor($(view).scrollTop() + ( ($(view)[0].scrollHeight - ele.get(0).offsetTop ) - ($(view).height() + $(view).offset().top - $(ele).offset().top) ));
};

function scrollease(element,pos,ease,duration) {
    element = document.getElementById(element);
    $(element).animate({
        scrollTop: pos
    }, {
        duration: duration,
        specialEasing: {
            scrollTop: ease
        }
    });
};

//Anote#17
// typewriter initialization typewriter code is modified from a public library
function typewriterstart(t,s) {
    // set up text to print, each item in array is new line
    aText = new Array(t);

    iSpeed = 24; // time delay of print out
    iIndex = 0; // start printing array at this posision
    iArrLength = aText[0].length; // the length of the text array
    iScrollAt = 20; // start scrolling up at this many lines

    iTextPos = 0; // initialise text position
    sContents = ''; // initialise contents variable
    iRow = null; // initialise current row
    typewriter();
}

//Anote#18
// typewriter recursive function iterates over the characters and types them
// out in an animated fashion based on initialized settings
function typewriter() {
    //debuglog('working on',iTextPos);
    sContents =  ' ';
    iRow = Math.max(0, iIndex-iScrollAt);
    var destination = document.getElementById("typedtext");
    if(destination){
        while ( iRow < iIndex ) {
            sContents += aText[iRow++] + '<br />';
        }
        if(aText[iIndex]){
            destination.innerHTML = sContents + aText[iIndex].substring(0, iTextPos) + "";
            if ( iTextPos++ == iArrLength ) {
                iTextPos = 0;
                iIndex++;
                if ( iIndex != aText.length ) {
                    iArrLength = aText[iIndex].length;
                    setTimeout("typewriter()", iSpeed);
                }
            } else {
                setTimeout("typewriter()", iSpeed);
            }
        } else {
            setTimeout("typewriter()", iSpeed);
        }
    }
}

////////////////////////////////
//Save/load
////////////////////////////////
/*function check_savepoint(){
	$.ajax({
		url: "user/dbcalls.php",
		method:"POST",
		data:{q:'check_savepoint',name:'savepoint'}
	}).done(function(json) {
		jsonobj = JSON.parse(json);
		vdump(jsonobj,'checked savepoint');
		if(_inkStory.variablesState["is_loaded_game"]){
			_inkStory.variablesState["is_loaded_game"] = jsonobj;
		}
	});
}*/
function save_to(sname,spath){
    return;
    //save_game(sname);
    //return;
    n("saving game to "+sname);
    gamestate[sname] = {};
    //gamestate[name].win = JSON.stringify(state);
    state.savepath = state.savePointer.container._path._componentsString;
    gamestate[sname].ink= _inkStory.state.toJson();
    //gamestate[sname].extstate= JSON.stringify(state, getCircularReplacer());
    /*stateobj = {
        gamewasloaded: true
    }
    gamestate[sname].extstate = JSON.stringify(stateobj);*/
    //gamestate[name].html = state.toJson();
    if(sname=="newgamestart"){
        newgamestate.ink = _inkStory.state.toJson();
    }
    $.ajax({
        url: "user/dbcalls.php",
        method:"POST",
        data:{q:'save_game',name:sname,savepath:spath,json:gamestate[sname].ink}
    }).done(function(json) {
        jsonobj = JSON.parse(json);
        n("saved game "+sname);
        //n(jsonobj);
    });
}
function save_game(sname){
    if(sname=="restart") sname="newgamestart";

    //for saving only during choices
    /*if(!$("#choices").hasClass("show") && sname!="newgamestart"){
        alert("Saving enabled during choices");
        return;
    }*/
    if(!load_db) {
        return;
    }
    if(sname=="newgamestart"){
        set_newgame=db_check_newgame_set();
        console.log('checking if newgame set',set_newgame);
        if(set_newgame) return false;

    }
    console.log("saving game "+sname);
    gamestate[sname] = {};
    if(!isset(state.savepath)){
        state.savepath = "global decl";
    }
    console.log('savepath',state.savepath);

    gamestate[sname].ink= _inkStory.state.toJson();
    statevars = {};
    for(var k in state){
        if(typeof state[k] === 'object' && state[k] !== null){
        }
        else {
            statevars[k] = state[k];
        }
    }
    var html_arr = '';
    var t_ele = $("#story p.show.parsed")[0];
    if(isset(t_ele)) html_arr = $("#story p.show.parsed")[0].outerHTML + "\n";
    $("#story p.show.parsed").nextAll().each(function(k,v){
        console.log('test',v);
        if(isset(v)) {
            console.log('each',k,v);
            html_arr = html_arr + v.outerHTML + "\n";
        }
    });
    //console.log(html_arr);

    statevars['html'] = html_arr;
    statejson = JSON.stringify(statevars);
    sobj = {
        name:sname,
        savepath:state.savepath,
        json:gamestate[sname].ink,
        state:statejson,
        extstate:''
        //extdata:
    }
    console.log("saving game",sobj);
    db_save_game(sobj);
    n("saved game "+sname);
}
function save_game_php(sname){
    n("saving game "+sname);
    gamestate[sname] = {};
    //gamestate[name].win = JSON.stringify(state);
    state.savepath = state.savePointer.container._path._componentsString;
    gamestate[sname].ink= _inkStory.state.toJson();
    //gamestate[sname].extstate= JSON.stringify(state, getCircularReplacer());
    /*stateobj = {
        gamewasloaded: true
    }
    gamestate[sname].extstate = JSON.stringify(stateobj);*/
    //gamestate[name].html = state.toJson();
    if(sname=="newgamestart"){
        newgamestate.ink = _inkStory.state.toJson();
    }
    $.ajax({
        url: "user/dbcalls.php",
        method:"POST",
        data:{q:'save_game',name:sname,savepath:state.savepath,json:gamestate[sname].ink}
    }).done(function(json) {
        jsonobj = JSON.parse(json);
        n("saved game "+sname);
    });
}
function load_game_raw_php(sname){
    $.ajax({
        url: "user/dbcalls.php",
        method:"POST",
        data:{q:'load_game',name:sname}
    }).done(function(json) {
        debuglog("retrieved game",sname);

        n("load gamestate "+sname);
        _inkStory.state.LoadJson(json);

        $("#choices").empty();
        //If choices are pending to be parsed they will cause double choices effect
        $("#story > p.choice").remove();

        //_inkStory.ChoosePathString(path);
        setTimeout(function(){
            continueStory();
            newPs();
            $("#continue").click();
            sync_watchvars();
        }, 1000);
    });
}
function load_game_by_id(load_game_id){
    loadinggame = true;
    console.log('loading game by id',load_game_id);
    ret = db_load_game(load_game_id);
    return load_game_from_obj(ret);
    /*json = ret['json'];
    savepath = ret['savepath'];

    state.savepath = savepath;
    if(state.savepath=="global decl") state.savepath = "0";
    //debuglog('found savepath',state.savepath);
    console.log('loading path',state.savepath);
    go_to_path(state.savepath)

    //sync_watchvars();
    loadinggame = false;
    return true;*/
}
var loadstateobj = {};
var initial_vars = false;
//var update_vars_by_prefix = ['ENEMY_','NPC_','VFX_','BG_'];
var do_restart=false;
function load_game_from_obj(ret){
    //var curversion = _inkStory.variablesState._defaultGlobalVariables;
    //console.log('loading game from obj',ret);
    json = ret['json'];
    if(!initial_vars){
        initial_vars = {};
        for(let m in _inkStory.variablesState._defaultGlobalVariables){
            initial_vars[m] = _inkStory.variablesState[m];
        }

    }

    _inkStory.state.LoadJson(json);

    for(let m in initial_vars){
        let update_save_var = false;
        for(let k in update_vars_by_prefix){
             let prefix=update_vars_by_prefix[k];
             if(m.startsWith(prefix)) update_save_var = true;
        }
        console.log('checking',initial_vars[m]);
        if(typeof _inkStory.variablesState[m] == "undefined" || _inkStory.variablesState[m]=="" || !_inkStory.variablesState[m] || update_save_var){
            console.log('updating',_inkStory.variablesState[m]);
            _inkStory.variablesState[m] = initial_vars[m];
        }
    }
    /*console.log('curversion after',curversion);
    for(let m in curversion){
        console.log('checking variable',m);
        if(typeof _inkStory.variablesState._defaultGlobalVariables[m] == "undefined"){
            console.log('check failed loading variable',m);
            _inkStory.variablesState._defaultGlobalVariables[m] = curversion[m];
        }
        else {
            console.log('checked variable',m,_inkStory.variablesState._defaultGlobalVariables[m],curversion[m] );
        }
    }*/
    load_registry();
    savepath = ret['savepath'];
    if(!savepath){
        alert('無法讀取遊戲：找不到存檔紀錄。');
        return false;
    }
    var loadstate = ret['state'];
    console.log('loading state',loadstate);
    loadstateobj = JSON.parse(loadstate);
    for(var k in loadstateobj){
        console.log('loading state',k);
        state[k] = loadstateobj[k];
    }
    console.log('loading savepath',savepath);
    if(!isset(savepath)){
        console.log('savepath does not exist');
        return false;
    }
    state.savepath = savepath;
    console.log('after savepath checks');

    //debuglog('found savepath',state.savepath);
    //go_to_path(state.savepath)
    //if(state.savepath=="global decl") state.savepath = "0";
    //if(state.savepath=="global decl") gamereset = 1;
    gamereset = 1;

    //go_to_path(state.savepath);
    if(!do_restart){
         go_to_path('SexenaMap.0.maptop.c-1');
    }
    else {
         go_to_path('TitleScreen');
    }
    do_restart=false;
    $("#story p.parsed").removeClass("show");
    $("#story p.parsed").addClass("hide");
    //hide($("#choices"));

    //working code to load html but it breaks reader
    /*$("#loadhtml").html('');
    var cont = document.getElementById("loadhtml");
    var parser = new DOMParser();
    var doc = parser.parseFromString("<top>" +loadstateobj['html']+ "</top>", "text/xml");
    //var doc = parser.parseFromString("<top>" + '<p>\n<div>test</div>\n</p>' + "</top>", "text/xml");
    var topchild = doc.firstChild;
    console.log(topchild);
    $(topchild).remove(".choice");

    var child = topchild.firstChild;
    while (child) {
        cont.appendChild(child);
        // Remove the extra junk added by the XML parser.
        //console.log('adding child',child);
        if(child.removeAttribute) child.removeAttribute("xmlns");
        child = topchild.firstChild;
    }
    console.log($("#loadhtml").html());
    $($("#loadhtml > p").get().reverse()).each(function() {
        if(!$(this).hasClass("choice")){
            $(this).prependTo($("#story"));
        }
        console.log(this);
    });*/
    //$("#loadhtml").html().clone().appendTo("#story");
    //$("#story").prepend($("#loadhtml").html());

    //sync_watchvars();
    loadinggame = false;
    continuedisabled=false;
    disablekeys=false;
    return true;
}

//var loadnew = false;

function load_game(sname){
     console.log('loading game '+sname);
    if(freshload && sname=="newgamestart"){
         console.log('freshload is true');
        freshload=false;
        return;
    }
    if(!load_db) {
         console.log('loading db not true');
        return;
    }
    console.log('loading game',sname);
    console.log(state.savePointer);

    if(!isset(state.savePointer)){
        console.log('skipping load no savepointer');
        return;
    }
    /*if(sname=="newgamestart" && !loadnew){
        console.log('skipping load due to flag');
        loadnew = true;
        return;
    }*/

    //set_debuglevel(3);
    //debuglog('loading game',sname);
    //load_game_raw(sname);
    //return;
    loadinggame = true;
    ret = db_load_game_by_name(sname);
    console.log("returned",ret);
    if(!ret){
        alert("這個欄位沒有遊戲存檔！");
        return;
    }
    return load_game_from_obj(ret);

    /*$.ajax({
        url: "user/dbcalls.php",
        method:"POST",
        data:{q:'load_game',name:sname}
    }).done(function(json) {
        if(newgamestate.ink){
            jsonobj = JSON.parse(json);
            ng_jsonobj = JSON.parse(newgamestate.ink);
            ng_jsonobj.variablesState = jsonobj.variablesState;
            //ng_jsonobj.currentChoices = jsonobj.currentChoices;
            ng_jsonobj.callStack = jsonobj.callStack;
            finaljson = JSON.stringify(ng_jsonobj);
        }
        else {
            finaljson = json;
        }
        //debuglog('ng_jsonobj',ng_jsonobj);
        //debuglog("retrieved game",sname);
        if(finaljson.length == 0){
            fatal("Can not load game as gamefile is empty");
            return;
        }
        //n(jsonobj);
        gamestate[sname] = {};

        gamestate[sname].ink = json;
        if(gamestate[sname]){
            n("load gamestate "+sname);
            //debuglog(gamestate[sname].ink);
            //_inkStory.state.LoadJson(gamestate[sname].ink);
            //if(sname=="savepoint"){
                //ng_jsonobj.variablesState = jsonobj.variablesState;
                //ng_jsonobj.currentChoices = jsonobj.currentChoices;
                //sjson = JSON.stringify(ng_jsonobj);
                //_inkStory.state.LoadJson(sjson);
                //_inkStory.state.LoadJson(finaljson);
                //_inkStory.variablesState["loaded_savepoint"] = true;
            //}
            //else if(loadgamestyle=="variables_only") _inkStory.state.LoadJson(finaljson);
            //else _inkStory.state.LoadJson(json);
            _inkStory.state.LoadJson(json);
            $.ajax({
                url: "user/dbcalls.php",
                method:"POST",
                data:{q:'get_savepath',name:sname}
            }).done(function(spath) {
                state.savepath = '';
                state.savepath = spath;
                //debuglog('found savepath',state.savepath);
                go_to_path(state.savepath)
                sync_watchvars();
                loadinggame = false;
            });
        //	_inkStory.ChoosePathString("Game");
            //_inkStory.state.LoadJson(ng_jsonobj);
            //_inkStory.state.LoadJson(jsonobj);
        }
    });*/
    //debuglog('load prevobj',_inkStory.state.previousContentObject);
    //debuglog('load nextobj',_inkStory.state.currentContentObject);
    /*if(gamestate[name]){
        state = JSON.parse(gamestate[name].win);
    }
    else {
        w("Could not load game "+ name);
    }*/
}
function restart_game(){

}
function go_to_path(path){
    console.log('going to savepath',path);
    for(var i in state.sound_cache){
        state.sound_cache[i].stop();
    }
    /*var clearstage = `clear:text howler:sound/:"action:'stop()'" bg:clear fg:clear scene:clear actor:clear cutaway:clear effect:clear effect2:clear fg:clear cutaway:clear cutawayframe:clear frame:img/screenframe.png:'alpha:1' set_var:optionstyle:box`;
    //state.filter_map.dreamfilter.enabled = false;
    $("#parsetxt").html(clearstage);

    for(var i in ancr_containers){
        var ac = ancr_containers[i].children;
        ////console.log('clear ac children',ac);
        for(var k in ac){
            ac[k].visible = false;
        }

    }

    var bgtext = state.lastbgchange;
    var replacelocal =  [replacepatterns.load,replacepatterns.save];
    for(var k in replacelocal){
        v = replacelocal[k];
        bgtext = bgtext.replace(v[0],v[1]);
    }
    console.log('bgtext',bgtext);
    $("#parsetxt").html(bgtext);
    parsetext($("#parsetxt"));*/


    $("#choices").empty();
    $("#story .unparsed").remove();
    $("#story .show.parsed").html('');
    //If choices are pending to be parsed they will cause double choices effect
    $("#story > p.choice").remove();

    _inkStory.ChoosePathString(path);
    continueStory();
    newPs();
    $("#continue").click();
}


function load_game_php(sname){
    //set_debuglevel(3);
    debuglog('loading game',sname);
    //load_game_raw(sname);
    //return;
    loadinggame = true;
    $.ajax({
        url: "user/dbcalls.php",
        method:"POST",
        data:{q:'load_game',name:sname}
    }).done(function(json) {
        if(newgamestate.ink){
            jsonobj = JSON.parse(json);
            ng_jsonobj = JSON.parse(newgamestate.ink);
            ng_jsonobj.variablesState = jsonobj.variablesState;
            //ng_jsonobj.currentChoices = jsonobj.currentChoices;
            ng_jsonobj.callStack = jsonobj.callStack;
            finaljson = JSON.stringify(ng_jsonobj);
        }
        else {
            finaljson = json;
        }
        //debuglog('ng_jsonobj',ng_jsonobj);
        debuglog("retrieved game",sname);
        if(finaljson.length == 0){
            fatal("Can not load game as gamefile is empty");
            return;
        }
        //n(jsonobj);
        gamestate[sname] = {};

        gamestate[sname].ink = json;
        if(gamestate[sname]){
            n("load gamestate "+sname);
            //debuglog(gamestate[sname].ink);
            //_inkStory.state.LoadJson(gamestate[sname].ink);
            //if(sname=="savepoint"){
            /*ng_jsonobj.variablesState = jsonobj.variablesState;
            ng_jsonobj.currentChoices = jsonobj.currentChoices;
            sjson = JSON.stringify(ng_jsonobj);
            _inkStory.state.LoadJson(sjson);*/
            //_inkStory.state.LoadJson(finaljson);
            //_inkStory.variablesState["loaded_savepoint"] = true;
            //}
            //else if(loadgamestyle=="variables_only") _inkStory.state.LoadJson(finaljson);
            //else _inkStory.state.LoadJson(json);
            _inkStory.state.LoadJson(json);
            $.ajax({
                url: "user/dbcalls.php",
                method:"POST",
                data:{q:'get_savepath',name:sname}
            }).done(function(spath) {
                state.savepath = '';
                state.savepath = spath;
                debuglog('found savepath',state.savepath);
                go_to_path(state.savepath)
                sync_watchvars();
                loadinggame = false;
            });
            //	_inkStory.ChoosePathString("Game");
            //_inkStory.state.LoadJson(ng_jsonobj);
            //_inkStory.state.LoadJson(jsonobj);
        }
    });
    //debuglog('load prevobj',_inkStory.state.previousContentObject);
    //debuglog('load nextobj',_inkStory.state.currentContentObject);
    /*if(gamestate[name]){
        state = JSON.parse(gamestate[name].win);
    }
    else {
        w("Could not load game "+ name);
    }*/
}
/*function go_to_path(path){
	$("#choices").empty();
	//If choices are pending to be parsed they will cause double choices effect
	$("#story > p.choice").remove();
	_inkStory.ChoosePathString(path);
	continueStory();
	newPs();
	$("#continue").click();
}*/
function sync_watchvars(){
    for(var i in watchvars_arr){
        var entry = watchvars_arr[i];
        //_inkStory.ObserveVariable(entry,update_observed_stat);
        var inkyvalue = _inkStory.variablesState[entry];
        update_observed_stat(entry,inkyvalue);
    }
}


function load_file() {
    var input, file, fr;
    if (typeof state.FileReader !== 'function') {
        alert("這個瀏覽器尚未支援檔案功能。");
        return;
    }
    input = document.getElementById('fileinput');
    if (!input) {
        alert("找不到檔案選取欄位。");
    }
    else if (!input.files) {
        alert("這個瀏覽器似乎不支援檔案選取功能。");
    }
    else if (!input.files[0]) {
        alert("請先選擇檔案，再按「讀取」。");
    }
    else {
        file = input.files[0];
        fr = new FileReader();
        fr.onload = received_text;
        fr.readAsText(file);
    }
    function received_text(e) {
        lines = e.target.result;
        _inkStory.state.LoadJson(lines);
        var savedstate = JSON.parse(lines);
        $("#story").html(savedstate.htmlstate);
    }
}



///////////////////////////////
// Achievements
///////////////////////////////
achievement_list = [];
user_achievements = [];
function check_achievement(a){
    for(var i in achievement_list){
        var v = achievement_list[i];
        if(v.code_name==a) return true;
    }
    return false;
}
function get_achievement_id(a){
    for(var i in achievement_list){
        var v = achievement_list[i];
        if(v.name==a) return v.achievement_id;
    }
    return false;
}
function get_full_achievement_name(code_name){
    astr = String(code_name);
    //debuglog('looking for',code_name,'in',state.flag_map[astr],state.flag_map);
    if(state.flag_map[astr]){
        return state.flag_map[astr];
    }
    else return '';
}
/*function get_achievement_list(){
	//debuglog('alist');
	var jqxhr = $.ajax( "user/dbcalls.php?q=get_achievement_list" )
		.done(function(data){
			achievement_list = JSON.parse(data);
			vdump(achievement_list,'got achievement list ');
		});
	return jqxhr;
}*/
function check_user_achievement(achievement_name){
    //debuglog(user_achievements);
    for(var i in user_achievements){
        var v = user_achievements[i];
        if( v.code_name == achievement_name){
            n("found user achievement "+achievement_name);
            return 1;
        }
    }
    n("did not find user achievement "+achievement_name);
    return 0;
}
/*function get_user_achievements(){
	var jqxhr = $.ajax( "user/dbcalls.php?q=get_user_achievements")
		.done(function(data){
			user_achievements = JSON.parse(data);
			vdump(user_achievements,'user_achievements ');
		});
	return jqxhr;
}*/
/*function add_achievement(getstr){
	//&name=Achievement+Name&code_name=flag_test&description=Description
	//debuglog('achievment add'+getstr);
	var jqxhr = $.ajax( "user/dbcalls.php?q=add_achievement"+getstr)
		.done(function(data){
			vdump(getstr,'added achievement ');
			//update list after
			//get_achievement_list();
		});
	return jqxhr;
}*/
function get_achievement_object(achievement_id){
    for(var i in achievement_list){
        var v = achievement_list[i];
        if(v.achievement_id==achievement_id){
            return v;
        }
    }
    return 'achievement not found';
}
/*function add_user_achievement(achievement_id){
	var jqxhr = $.ajax( "user/dbcalls.php?q=add_user_achievement&achievement_id="+achievement_id)
		.done(function(data){
			vdump(achievement_id,'added user achievement ');
			aobj = get_achievement_object(achievement_id);
			//debuglog('achievement obj',aobj);
			displayAchievement("Earned Achievement!",aobj.name);
			//update list after
			get_user_achievements();
			if(aobj){
				_inkStory.variablesState["flag_"+aobj.code_name] = 1;
				//debuglog('achievement '+ aobj.code_name +'in ink set to ',_inkStory.variablesState['flag_'+aobj.code_name]);
			}
		});
}*/

///////////////////////////////////
// Helper/utility functions
///////////////////////////////////
// this is now deprecated
function file_ext(){
    return fname.slice((Math.max(0, fname.lastIndexOf(".")) || Infinity) + 1);
}
//Anote#24
// callback function for turning javascript object into a JSON string, JSON
// stringify fails if the object contains a reference to itself this is a way
// to be able to dump and look at (and search over) an entire object, like the
// inkStory object, which contains self referential properties being able to
// see the entire object and search over it ets you reverse engineer and
// develop much faster/easier in some cases
const getCircularReplacer = () => {
    const seen = new WeakSet();
    return (key, value) => {
        if (typeof value === "object" && value !== null) {
            if (seen.has(value)) {
                return;
            }
            seen.add(value);
        }
        return value;
    };
};

//Anote#25
// callback functions for sorting with javascript.  A general comparison but
// used to ensure layers get the same sort order in multiple browsers and
// ensure we have the sort order defined by inky for pixi layers inky layers
// are converted to z values, which you can think of like z-index in CSS
function depthReverseCompare(a, b){  if (a.z < b.z)     return -1;  if (a.z > b.z)    return 0;  return 1;}
function depthCompare(a, b){
    if(typeof a.z == "undefined") a.z = 999;
    if(typeof b.z == "undefined") b.z = 999;
    //debuglog('sorting',a.z,b.z);
    if (a.z < b.z) return -1;
    else if (a.z > b.z) return 1;
    else return 0;
}

//Anote#35
// function used for achievements/flags, which returns the flag's name given a
// code ex beat_game would return Finished Game or whatever it was defined by
// inky

function get_code_name(a){
    //debuglog('a',a,state.flag_map);
    for(var i in state.flag_map){
        var v = state.flag_map[i];
        //debuglog('iv',i,v);
        if(v==a){
            return i;
        }
    }
    return '';
}

////////////////////////////////////////////
// Console commands and utility functions
////////////////////////////////////////////
function container_stats(name){
    cref = state['acontainer_'+name];
    debuglog(name,'w:',cref.width,'h:',cref.height,'x:',cref.position.x,'y:',cref.position.y);
    for(var i in cref.children){
        v = cref.children[i];
        debuglog(v.constructor.name,'w:',v.width,'h:',v.height,'x:',v.position.x,'y:',v.position.y);
    }
}

// console command to not have to get a containers child by index without having to remember the long data structure
function container_child(name,index){
    return state['acontainer_'+name].children[index];
}

//outputs the pixi stage's children in order
function show_children_order(){
    for(var i in stage.children){
        debuglog(stage.children[i].cname,stage.children[i].z,i);
    }
}
//hides all layers on the stage
function hide_all_layers(){
    for(var i in stage.children){
        stage.children[i].visible = false;
    }
}
//shows all layers on the stage
function show_all_layers(){
    for(var i in stage.children){
        stage.children[i].visible = true;
    }
}
//hide layer by index
function hide_layer(i){
    stage.children[i].visible = false;
}
//show layer by index
function show_layer(i){
    stage.children[i].visible = true;
}
function show_layer_byname(name){
    cref = state['acontainer_'+name];
    cref.visible=true;
}
//show the profiles
function show_profile_arr(){
    profile_arr.sort(function(a,b) {
        return a.time - b.time;
    });
    debuglog('sorted profiles',profile_arr);
}

//mapped to the textbox toggle button
function toggle_textbox(){
    $("#textbox").toggle();
    /*$("#showtextbox").toggle();*/
}
function assign_rightclick(){
    if(!debugmode) document.oncontextmenu = function() {return false;};
    $(document).mousedown(function(e){
        if( e.button == 2 ) {
            toggle_textbox();
            return false;
        }
        return true;
    });
    $("#showtextbox").click(toggle_textbox);
}

// outlines pixi container by name
function outline_container(name){
    cref = state['acontainer_'+name];
    var graphics = new PIXI.Graphics();
    //graphics.beginFill(0xFFFF00);

    // set the line style to have a width of 5 and set the color to red
    graphics.lineStyle(5, 0xFF0000);
    // draw a rectangle
    graphics.drawRect(0, 0, cref.width+10, cref.height+10);
    cref.addChild(graphics);
}

function matchid(elementid) {
    const {id, element, text,tags} = storyid.get(elementid);
    debuglog("%ID:",id)
    debuglog("%ELEMENT:",element)
    debuglog("%TEXT:",text)
    debuglog("%TAGS:",tags)
}

//parsetextraw("actor:img/tootie.json:0:'cx:0,cy:900,scale:1,loop:1,timescale:1'");
function parsetextraw(txt){
    if($("#parseraw").length > 0){

    }
    else {
        $('body').append("<div id='parseraw'></div>");
    }
    ele = $("#parseraw");
    ele.html(txt);
    parsetext(ele);
}
function fillcontainer(name){
    var fillg = new PIXI.Graphics();
    fillg.beginFill(0x00FFFF, 0);
    fillg.drawRect(0, 0, render_width, render_height);
    //debuglog('render',render_width,render_height);
    fillg.endFill();
    state['acontainer_'+name].addChild(fillg);
    state['acontainer_'+name].visible = true;
}
function testimage(){
    // create a new Sprite from an image path
    var bunny = PIXI.Sprite.fromImage('img/neri_0.png')

    // center the sprite's anchor point
    bunny.anchor.set(0.5);

    // move the sprite to the center of the screen
    bunny.x = 100;
    bunny.y = 100;
    state['acontainer_actor'].addChild(bunny);

    /*app.stage.addChild(bunny);

    // Listen for animate update
    app.ticker.add(function(delta) {
        // just for fun, let's rotate mr rabbit a little
        // delta is 1 if running at 100% performance
        // creates frame-independent transformation
        bunny.rotation += 0.1 * delta;
    });*/
}
