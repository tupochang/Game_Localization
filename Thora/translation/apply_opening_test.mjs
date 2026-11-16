import fs from 'node:fs/promises';
import path from 'node:path';

const root = path.resolve(import.meta.dirname,'..');
const mapPath = path.join(root,'www/data/Map002.json');
const systemPath = path.join(root,'www/data/System.json');
const pluginPath = path.join(root,'www/js/plugins.js');
const backupDir = path.join(import.meta.dirname,'backup_original');
await fs.mkdir(backupDir,{recursive:true});
const {opening,systemTranslations} = JSON.parse(await fs.readFile(path.join(import.meta.dirname,'opening_test.json'),'utf8'));
for (const src of [mapPath,systemPath,pluginPath]) {
  const dest=path.join(backupDir,path.basename(src));
  try { await fs.access(dest); } catch { await fs.copyFile(src,dest); }
}
const map=JSON.parse(await fs.readFile(mapPath,'utf8'));
const commands=map.events[2].pages[0].list;
for(const [i,value] of Object.entries(opening)){
  const command=commands[Number(i)];
  if(command?.code!==401)throw new Error(`Unexpected command at ${i}`);
  command.parameters[0]=value;
}
await fs.writeFile(mapPath,JSON.stringify(map),'utf8');
const system=JSON.parse(await fs.readFile(systemPath,'utf8'));
system.gameTitle=systemTranslations.gameTitle;
system.locale='zh_TW';
for(const [key,value] of Object.entries(systemTranslations)){
  const match=key.match(/^terms\.commands\.(\d+)$/);
  if(match)system.terms.commands[Number(match[1])]=value;
}
await fs.writeFile(systemPath,JSON.stringify(system),'utf8');
let plugins=await fs.readFile(pluginPath,'utf8');
const from='"Chinese Font":"SimHei, Heiti TC, sans-serif"';
const to='"Chinese Font":"Microsoft JhengHei, MingLiU, sans-serif"';
if(!plugins.includes(from)&&!plugins.includes(to))throw new Error('Chinese font setting not found');
plugins=plugins.replace(from,to);
await fs.writeFile(pluginPath,plugins,'utf8');
console.log(`Applied ${Object.keys(opening).length} opening lines, ${Object.keys(systemTranslations).length} UI strings; backup: ${backupDir}`);
