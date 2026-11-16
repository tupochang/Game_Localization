import fs from 'node:fs/promises';
import path from 'node:path';
import {FileBlob,SpreadsheetFile} from '@oai/artifact-tool';

const dir=import.meta.dirname;
const input=path.join(dir,'托拉的勇者_劇情翻譯_NEW.xlsx');
const backup=path.join(dir,'托拉的勇者_劇情翻譯_NEW_校對前備份.xlsx');
try{await fs.access(backup);}catch{await fs.copyFile(input,backup);}
const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(backup));
const sheet=wb.worksheets.getItem('道具技能資料');
const values=sheet.getRange('A1:I475').values;
const fixes={
  12:'施放聖光！',13:'施放淨化！',14:'施放復活！',
  22:'使出強力重擊！',23:'使出破甲重擊！',
  30:'施放暗影衝擊！',32:'使出夜之爪！',
  48:'施放托拉的怒火！',53:'施放毒浪！',55:'施放混亂衝擊！',
  59:'噴出黑暗吐息！',60:'使出毒咬！',61:'噴出毒息！',
  64:'使出地獄連擊！',65:'施放地獄衝擊！',66:'施放恐怖之觸！',
  68:'發出復仇咆哮！',69:'使出恐懼迴響！'
};
let changed=0;
for(let i=1;i<values.length;i++){
  const row=values[i];
  if(row[1]!=='Skills.json'||row[3]!=='message1')continue;
  const id=Number(row[2]);
  if(!Object.hasOwn(fixes,id))continue;
  sheet.getRange(`F${i+1}`).values=[[fixes[id]]];
  changed++;
}
if(changed!==Object.keys(fixes).length)throw new Error(`Expected ${Object.keys(fixes).length} fixes, found ${changed}`);
let namesFixed=0;
for(const [tab,max] of [['道具技能資料',475],['介面與地圖',276]]){
  const target=wb.worksheets.getItem(tab);
  const rows=target.getRange(`A1:I${max}`).values;
  for(let i=1;i<rows.length;i++){
    const value=rows[i][5];
    if(typeof value==='string'&&value.includes('薩爾瑪')){
      target.getRange(`F${i+1}`).values=[[value.replaceAll('薩爾瑪','莎爾瑪')]];
      namesFixed++;
    }
  }
}
if(namesFixed!==3)throw new Error(`Expected 3 Salma names, found ${namesFixed}`);
const blob=await SpreadsheetFile.exportXlsx(wb);
await blob.save(input);
console.log(JSON.stringify({backup,correctedBattleMessages:changed,correctedNames:namesFixed,output:input}));
