import fs from 'node:fs/promises';
import path from 'node:path';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const root = path.resolve(import.meta.dirname, '..');
const out = import.meta.dirname;
const data = path.join(root, 'www', 'data');
const opening = {
  7:'露茲：',8:'我在這裡，母親。',12:'托拉：',13:'露茲，我的孩子。我一直擔憂的時刻',14:'終於來了……我有任務要交給妳。',17:'露茲：',18:'我聽候差遣。您要我做什麼？',19:'',22:'托拉：',23:'岡加即將復活。促成此事的齒輪',24:'早已轉動。我試著阻止，卻失敗了。',25:'他的歸來絕不會帶來好事。',27:'托拉：',28:'他的復仇將毫無止境。一切都會',29:'被毀滅。',32:'露茲：',33:'如果無法阻止他復活，我們就必須',34:'與他戰鬥。我準備好了，母親。',37:'托拉：',38:'妳知道自己不能上戰場。妳是我在',39:'世上的意志與聲音。我不能失去妳，',40:'孩子。但妳要為戰士們做好準備。',42:'托拉：',43:'我已選出四位勇者。他們是心懷',44:'高尚理想的凡人。去找到他們，',45:'召集他們迎接此生最大的',47:'托拉：',48:'試煉。',51:'露茲：',52:'……',53:'我是您的意志，必遵從您的命令。',56:'托拉：',57:'我們必須使用傳送門。快去取回',58:'兩道聖焰，才能啟動它。守護聖焰的',59:'魔物應該難不倒妳。',61:'托拉：',62:'',63:'去吧，孩子。帶著聖焰盡快回來。',66:'露茲：',67:'我很快就會回來。'
};
const systemTranslations = {
  'gameTitle':'托拉的勇者',
  'terms.commands.18':'新遊戲',
  'terms.commands.19':'繼續遊戲',
  'terms.commands.21':'返回標題',
  'terms.commands.22':'取消',
  'terms.commands.11':'選項',
};
const rows = [['來源檔案','地圖名稱','事件 ID','事件名稱','頁面(0起)','指令索引(0起)','類型','選項索引','英文原文','繁體中文','狀態']];
const files = (await fs.readdir(data)).filter(x=>/^Map\d+\.json$/.test(x)).sort();
let translated = 0;
for (const f of files) {
  const map = JSON.parse(await fs.readFile(path.join(data,f),'utf8'));
  for (const event of map.events || []) if (event) {
    event.pages.forEach((page,p) => page.list.forEach((command,i) => {
      if (command.code === 401 || command.code === 405) {
        const target = f === 'Map002.json' && event.id === 2 && p === 0 ? opening[i] : undefined;
        if (target !== undefined) translated++;
        rows.push([f,map.displayName||'',event.id,event.name,p,i,command.code===401?'對話':'捲動文字','',String(command.parameters[0]??''),target??'',target!==undefined?'測試已套用':'待翻譯']);
      } else if (command.code === 102) {
        command.parameters[0].forEach((choice,k)=>rows.push([f,map.displayName||'',event.id,event.name,p,i,'選項',k,String(choice), '','待翻譯']));
      }
    }));
  }
}
const system = JSON.parse(await fs.readFile(path.join(data,'System.json'),'utf8'));
for (const [key,value] of Object.entries({'gameTitle':system.gameTitle,'terms.commands.18':system.terms.commands[18], 'terms.commands.19':system.terms.commands[19], 'terms.commands.21':system.terms.commands[21], 'terms.commands.22':system.terms.commands[22], 'terms.commands.11':system.terms.commands[11]})) {
  rows.push(['System.json','標題畫面','','', '',key,'介面文字','',value,systemTranslations[key],'測試已套用']);
}
const wb = Workbook.create();
const sheet = wb.worksheets.add('劇情與開頭文字');
sheet.showGridLines = false;
sheet.getRangeByIndexes(0,0,rows.length,11).values = rows;
sheet.getRange('A1:K1').format.fill = '#17365D';
sheet.getRange('A1:K1').format.font.color = '#FFFFFF';
sheet.getRange('A1:K1').format.font.bold = true;
sheet.getRange('A:A').format.columnWidth = 19;
sheet.getRange('B:B').format.columnWidth = 24;
sheet.getRange('C:F').format.columnWidth = 15;
sheet.getRange('G:H').format.columnWidth = 13;
sheet.getRange('I:J').format.columnWidth = 62;
sheet.getRange('K:K').format.columnWidth = 16;
sheet.freezePanes.freezeRows(1);
const blob = await SpreadsheetFile.exportXlsx(wb);
await blob.save(path.join(out,'托拉的勇者_劇情翻譯對照表.xlsx'));
await fs.writeFile(path.join(out,'opening_test.json'),JSON.stringify({opening,systemTranslations},null,2),'utf8');
console.log(JSON.stringify({rows:rows.length-1,openingLines:translated,output:path.join(out,'托拉的勇者_劇情翻譯對照表.xlsx')}));
