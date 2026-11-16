function escMenu(){
    if(!can_save()){
        $("#savegame").addClass('grayscale');
    }
    else {
        $("#savegame").removeClass('grayscale');
    }
    $("#esccontainerwrap").toggle();
    if($("#esccontainerwrap").is(":visible")){
        disablekeys = true;
    }
    else {
        disablekeys = false;
    }
    $("#savegamebox").hide();
    $("#loadgamebox").hide();
    $("#escmenu-list").show();
}
function can_save(){
    //disable_startsave = "0.restart_game.start_game.mainmenu.mainmenureturn.0.c global decl";
    disable_startsave = "TitleScreen.1.titlenosound.menutop";
    let curpointer = String(state.savePointer);
    //console.log('start save',disable_startsave.includes(state.savePointer),"'",state.savePointer,"'",disable_startsave);
    if($("#choices").hasClass("visible") && !curpointer.includes(disable_startsave)){
        return true;
    }
    else return false;
}
$(document).ready(function(){
    $(document).keyup(function(e) {
        //if (e.keyCode === 13) $('.save').click();     // enter
        if (e.keyCode === 27) escMenu();
    });
    $("#savebox").click(escMenu);
    $("#escexit").click(escMenu);
    app = require('electron').remote.app;
    const path = require('path');
    basepath = app.getPath('userData');
    //basepath = app.getAppPath();
    require('electron-disable-file-drop');
    //console.log('basepath',basepath);
    $("#savegame").click(function(){
        if(!can_save()){
            alert("只能在出現劇情選項時儲存遊戲。");
            return;
        }
        if(!load_db){
            alert("無法載入儲存、讀取及重新開始模組。請透過 Steam 聯絡客服尋求協助。");
            return;
        }

        $("#escmenu-list").hide();

        $("#saveform").show();
        $("#savemsg-success").hide();
        $("#savegamebox").show();

        var ts = new Date();
        //var datestr = ts.toLocaleString();
        save_ids = q("select max(save_id)+1 as save_id from user_saves");
        save_id=1;
        save_usernum=1;
        console.log(save_ids);
        if(save_ids[0]){
            save_id = save_ids[0].save_id;
        }
        if(save_id=='null' || save_id==null){
            save_id=1;
        }
        snum_temp = q("select count(save_id)+1 as save_id from user_saves where name!='newgamestart'");
        if(snum_temp[0]){
            save_usernum = snum_temp[0].save_id;
        }
        if(save_usernum=='null' || save_usernum==null){
            save_usernum=1;
        }

        console.log('save id',save_id);

        $("#savegame-name").val('Sexena－存檔 '+save_usernum);
        $("#savegame-name").focus();
    });
    $("#loadgame").click(function(){
        if(!load_db){
            alert("無法載入儲存、讀取及重新開始模組。請透過 Steam 聯絡客服尋求協助。");
            return;
        }
        $("#escmenu-list").hide();
        savedgames = q("select * from user_saves where name!='newgamestart' order by date desc");
        console.log(savedgames);
        savedhtml = '';
        fs = remote.require('fs');
        for(i in savedgames){
            s = savedgames[i];
            console.log(s);
            //s.save_id=1;
            let imgurl = `${basepath}${path.sep}ss${s.save_id}.png`;
            if (!fs.existsSync(imgurl)) {
                imgurl = "no-screenshot.png";
            }
            savedhtml=savedhtml+`<div id="sg${s.save_id}" class="sg-cont"><img src="${imgurl}"> ${s.name} - ${s.date} <button class="loadgame" save_id=${s.save_id}>讀取</button></div>`;
        }
        if(savedhtml.length==0){
            savedhtml = "<div>找不到存檔</div>"
        }
        $("#loadgamebox").html(savedhtml);
        $("#loadgamebox").removeClass("hidden");
        $("#loadgamebox .loadgame").click(function(ele){
            load_save_id = $(this).attr('save_id');
            load_game_by_id(load_save_id);
            escMenu();
        });
        $("#loadgamebox").show();
    });

    $("#restart").click(function(){
        freshload=false;
        do_restart=true;
        if(!load_db){
            alert("無法載入儲存、讀取及重新開始模組。請透過 Steam 聯絡客服尋求協助。");
            return;
        }
        load_game("newgamestart");
        escMenu();
    });
    console.log('restart button assigned');
    $("#quit").click(function(){
        if(confirm("確定要離開遊戲嗎？")){
            window.close();
        }
    });

    $("#saveform").submit(function(e){
        e.preventDefault();
        //saveid = 1;
        console.log('save id',save_id);
        filename=basepath+ path.sep +'ss'+save_id+'.png';
        console.log('saving cap',filename);
        $("#esccontainerwrap").toggle();
        var remote;
        try {
            remote = require('' + 'electron').remote;
        } catch (e) {
            remote = require('' + 'remote');
        }
        fs = remote.require('fs');
        remote.getCurrentWindow().capturePage(function handleCapture (img) {
            //console.log('img',img);
            fs.unlink('file.csv', function(err){
                // Ignore error if no file already exists
                if (err && err.code !== 'ENOENT')
                    throw err;
                fs.writeFile(filename, img.toPNG(), function(){
                    console.log('wrote file');
                    save_game($("#savegame-name").val());
                    $("#esccontainerwrap").toggle();
                    $("#saveform").hide();
                    $("#savemsg-success").show();
                });
            });
        });
        return false;
    });
    $("#savedgame").click(function(){
        $("#saveform").show();
        $("#savemsg-success").hide();
        $("#esccontainerwrap").toggle();
    });
});