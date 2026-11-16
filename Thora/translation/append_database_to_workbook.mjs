import fs from 'node:fs/promises';
import path from 'node:path';
import vm from 'node:vm';
import { FileBlob, SpreadsheetFile } from '@oai/artifact-tool';

const root=path.resolve(import.meta.dirname,'..');
const bookPath=path.join(import.meta.dirname,'托拉的勇者_劇情翻譯.xlsx');
const backupPath=path.join(import.meta.dirname,'托拉的勇者_劇情翻譯_追加前備份.xlsx');
const data=path.join(root,'www','data');
const databaseBackup=path.join(import.meta.dirname,'backup_before_database_20261016_191928','www','data');
const uiBackup=path.join(import.meta.dirname,'backup_before_ui_20261016_191453','www','data');
const originalBackup=path.join(import.meta.dirname,'backup_original');
const current=async f=>JSON.parse(await fs.readFile(path.join(data,f),'utf8'));
const old=async (f,folder)=>{
  const raw=await fs.readFile(path.join(folder,f),'utf8');
  return JSON.parse(f==='Difficulties.json'?raw.replace(/,\s*]/g,']'):raw);
};
const header=['類別','來源檔案','ID／位置','欄位／指令','英文原文','目前遊戲文字／譯文','狀態','定位鍵','備註'];
const dbRows=[header],uiRows=[header],eventRows=[header];
const skip=(v)=>v===null||v===undefined||String(v)==='';
function add(rows,category,file,id,field,english,translation,key,note=''){
  if(skip(english)&&skip(translation))return;
  const en=String(english??''),zh=String(translation??'');
  let status=zh===en?'待翻譯':'已套用';
  if(zh===en&&(/^(HP|MP|TP|EXP|Lv|\$|%\d+|\\G)$/i.test(en)||!/[A-Za-z\u4e00-\u9fff]/.test(en)))status='原文留用';
  rows.push([category,file,String(id),field,en,zh,status,key,note]);
}
const configs={
  'Items.json':['道具',['name','description']],
  'Skills.json':['技能',['name','description','message1','message2']],
  'Weapons.json':['武器',['name','description']],
  'Armors.json':['防具／飾品',['name','description']],
  'States.json':['狀態',['name','message1','message2','message3','message4']],
  'Enemies.json':['敵人',['name']],
  'Actors.json':['角色',['name','nickname','profile']],
  'Classes.json':['職業',['name']],
};
for(const [file,[category,fields]] of Object.entries(configs)){
  const live=await current(file);
  const original=await old(file,file==='Actors.json'||file==='Classes.json'?uiBackup:databaseBackup);
  for(let id=0;id<live.length;id++){
    const obj=live[id],src=original[id];
    if(!obj||!src||String(src.name||'').startsWith('//'))continue;
    for(const field of fields)add(dbRows,category,file,id,field,src[field],obj[field],`[${id}].${field}`);
  }
}
const system=await current('System.json');
const originalSystem=await old('System.json',originalBackup);
for(const field of ['gameTitle','currencyUnit'])add(uiRows,'系統','System.json','',field,originalSystem[field],system[field],field);
for(const field of ['armorTypes','equipTypes','skillTypes','weaponTypes','elements']){
  for(let i=0;i<system[field].length;i++)add(uiRows,'介面分類','System.json',i,field,originalSystem[field][i],system[field][i],`${field}[${i}]`);
}
for(const field of ['basic','commands','params']){
  const a=system.terms[field],b=originalSystem.terms[field];
  for(let i=0;i<a.length;i++)add(uiRows,'系統介面','System.json',i,`terms.${field}`,b[i],a[i],`terms.${field}[${i}]`);
}
for(const key of Object.keys(system.terms.messages).sort())add(uiRows,'系統訊息','System.json',key,'terms.messages',originalSystem.terms.messages[key],system.terms.messages[key],`terms.messages.${key}`,'保留 %1、%2、\\G 等控制碼');
const maps=(await fs.readdir(data)).filter(x=>/^Map\d+\.json$/.test(x)).sort();
for(const file of maps){
  const live=await current(file);
  if(!live.displayName)continue;
  const src=await old(file,uiBackup);
  add(uiRows,'地圖顯示名稱',file,'','displayName',src.displayName,live.displayName,'displayName');
}
const difficulty=await current('Difficulties.json');
const originalDifficulty=await old('Difficulties.json',databaseBackup);
for(let i=0;i<difficulty.length;i++)add(uiRows,'難度選項','Difficulties.json',i,'name',originalDifficulty[i].name,difficulty[i].name,`[${i}].name`);
const pluginCurrent=vm.runInNewContext(await fs.readFile(path.join(root,'www/js/plugins.js'),'utf8')+'\n$plugins;');
const pluginOriginal=vm.runInNewContext(await fs.readFile(path.join(import.meta.dirname,'backup_before_database_20261016_191928','www/js/plugins.js'),'utf8')+'\n$plugins;');
for(const [plugin,param] of [['SRD_FullscreenToggleOption','Option Name'],['YEP_FpsSynchOption','Command Name']]){
  const live=pluginCurrent.find(x=>x.name===plugin),src=pluginOriginal.find(x=>x.name===plugin);
  add(uiRows,'外掛選項','www/js/plugins.js',plugin,param,src.parameters[param],live.parameters[param],`${plugin}.parameters[${param}]`);
}
add(uiRows,'外掛選項','www/js/plugins/SSG_DifficultySetting.js','','選項標籤','Difficulty','難度',"this.addCommand('難度', 'difficulty')",'寫在外掛程式碼中');
add(uiRows,'選項狀態','www/js/rpg_windows.js','','booleanStatusText.true','ON','開','Window_Options.booleanStatusText(true)','寫在遊戲程式碼中');
add(uiRows,'選項狀態','www/js/rpg_windows.js','','booleanStatusText.false','OFF','關','Window_Options.booleanStatusText(false)','寫在遊戲程式碼中');
add(uiRows,'標題圖片','www/img/titles1/Champions of Thora.rpgmvp','','圖片文字','Champions of Thora','托拉的勇者','圖片資產','圖片內文字，須修改圖片');
for(const file of ['CommonEvents.json','Troops.json']){
  const arr=await current(file);
  for(const obj of arr)if(obj){
    const pages=file==='Troops.json'?obj.pages:[{list:obj.list}];
    for(let p=0;p<pages.length;p++){
      for(let i=0;i<(pages[p]?.list?.length||0);i++){
        const command=pages[p].list[i];
        const base=`[${obj.id}]${file==='Troops.json'?`.pages[${p}]`:''}.list[${i}].parameters[0]`;
        if(command.code===401||command.code===405)add(eventRows,file==='Troops.json'?'戰鬥事件':'共通事件',file,`${obj.id}/${p}/${i}`,command.code===401?'對話':'捲動文字',command.parameters[0],command.parameters[0],base,obj.name);
        else if(command.code===102)command.parameters[0].forEach((choice,k)=>add(eventRows,file==='Troops.json'?'戰鬥事件':'共通事件',file,`${obj.id}/${p}/${i}/${k}`,'選項',choice,choice,`${base}[${k}]`,obj.name));
      }
    }
  }
}
try { await fs.access(backupPath); } catch { await fs.copyFile(bookPath,backupPath); }
const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(backupPath));
for(const [name,rows] of [['道具技能資料',dbRows],['介面與地圖',uiRows],['其他事件文字',eventRows]]){
  if(rows.length===1)continue;
  const sheet=wb.worksheets.add(name);
  sheet.showGridLines=false;
  sheet.getRangeByIndexes(0,0,rows.length,9).values=rows;
  sheet.getRange('A1:I1').format.fill='#17365D';
  sheet.getRange('A1:I1').format.font.color='#FFFFFF';
  sheet.getRange('A1:I1').format.font.bold=true;
  sheet.getRange('A:A').format.columnWidth=17;
  sheet.getRange('B:B').format.columnWidth=30;
  sheet.getRange('C:D').format.columnWidth=18;
  sheet.getRange('E:F').format.columnWidth=52;
  sheet.getRange('G:G').format.columnWidth=14;
  sheet.getRange('H:H').format.columnWidth=47;
  sheet.getRange('I:I').format.columnWidth=29;
  sheet.freezePanes.freezeRows(1);
}
const result=await SpreadsheetFile.exportXlsx(wb);
await result.save(bookPath);
console.log(JSON.stringify({backup:backupPath,database:dbRows.length-1,interface:uiRows.length-1,extraEvents:eventRows.length-1,totalAdded:dbRows.length+uiRows.length+eventRows.length-3}));
