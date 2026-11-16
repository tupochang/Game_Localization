import datetime, json, pathlib, re, shutil

root=pathlib.Path(__file__).resolve().parents[1]
data=root/'www/data'
backup=root/'translation'/('backup_before_database_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
backup.mkdir()
def preserve(file):
    dest=backup/file.relative_to(root)
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(file,dest)
def write_json(file,obj):
    preserve(file)
    file.write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')),encoding='utf-8')

names={
'Skills':{
 'Attack':'攻擊','Guard':'防禦','Dual Attack':'雙重攻擊','Double Attack':'二連擊','Triple Attack':'三連擊','Escape':'逃跑','Wait':'待機',
 'Heal':'治療','Fire':'火焰','Spark':'電光','White Ray':'聖光','Purify':'淨化','Revive':'復活','Heal Rain':'治癒之雨',
 'Power Crush':'強力重擊','Vigor Crush':'破甲重擊','War Cry':'戰吼','Dark Blast':'暗影衝擊','Dark Void':'黑暗虛空','Night Claw':'夜之爪',
 'Double Shot':'二連射','Triple Shot':'三連射','Arrow Storm':'箭雨','Thora\'s Blessing':'托拉的祝福','Thora\'s Judgment':'托拉的審判','Thora\'s Wrath':'托拉的怒火',
 'Fire Breath':'火焰吐息','Poison Claw':'毒爪','Paralyze Slash':'麻痺斬','Poisoned Wave':'毒浪','Paralyze Bite':'麻痺咬擊','Confusion Blast':'混亂衝擊',
 'Judgment Eye':'審判之眼','All Attack':'全體攻擊','Sand Throw':'揚沙','Dark Breath':'黑暗吐息','Poison Bite':'毒咬','Poison Breath':'毒息',
 'Paralyze Claw':'麻痺爪','Intimidating Roar':'威嚇咆哮','Hell Flail':'地獄連擊','Hell Blast':'地獄衝擊','Dreaded Touch':'恐怖之觸',
 'Undead Army':'不死軍團','Vengeful Roar':'復仇咆哮','Echoes of Horror':'恐懼迴響'},
'Weapons':{
 'Iron Blade':'鐵劍','Ogre Slayer':'食人魔殺手','Moon Blade':'月之劍','Dragon Blade':'龍之劍','White Blade':'白之劍','Diamond Blade':'鑽石劍',
 'Thora Sword':'托拉之劍','Heavy Axe':'重斧','Dwarven Axe':'矮人斧','Behemot\'s Tail':'巨獸之尾','Golem Axe':'魔像斧','Hell Axe':'地獄斧',
 'Diamond Axe':'鑽石斧','Thora Axe':'托拉之斧','Apprentice\'s Book':'學徒之書','Initiated\'s Book':'入門之書','Necromancer\'s Book':'死靈法師之書',
 'Ancient Book':'古代之書','Holy Book':'聖書','Diamond Book':'鑽石之書','Thora Book':'托拉之書','Wooden Bow':'木弓',
 'Elite Bow':'精銳弓','Noble Bow':'貴族弓','Dwarven Bow':'矮人弓','White Bow':'白之弓','Diamond Bow':'鑽石弓','Thora Bow':'托拉之弓'},
'Armors':{
 'Breastplate':'胸甲','Captain\'s Armor':'隊長鎧甲','Soldier\'s Armor':'士兵鎧甲','Dwarven Armor':'矮人鎧甲','White Armor':'白色鎧甲',
 'Diamond Armor':'鑽石鎧甲','Azael Armor':'阿札爾鎧甲','Bronze Helmet':'青銅頭盔','Soldier\'s Helmet':'士兵頭盔','Stone Head':'石製頭盔',
 'Dwarven Helmet':'矮人頭盔','White Helmet':'白色頭盔','Diamond Helmet':'鑽石頭盔','Thora Armor':'托拉鎧甲','Thora Helmet':'托拉頭盔',
 'Traveler\'s Vest':'旅人背心','Orc Vest':'獸人背心','Elven Tunic':'精靈長袍','Soldier\'s Vest':'士兵背心','Dwarven Vest':'矮人背心',
 'Holy Robe':'聖袍','White Vest':'白色背心','Diamond Vest':'鑽石背心','Leather Bandana':'皮頭巾','Fighter\'s Bandana':'鬥士頭巾',
 'Dwarven Circlet':'矮人頭環','Holy Circlet':'神聖頭環','White Circlet':'白色頭環','Diamond Circlet':'鑽石頭環','Thora Vest':'托拉背心',
 'Thora Circlet':'托拉頭環','Wooden Targe':'木製小盾','Soldier\'s Shield':'士兵盾','Elven Shield':'精靈盾','Dwarven Shield':'矮人盾',
 'Volcano Stone':'火山石盾','Holy Shield':'神聖之盾','White Shield':'白色之盾','Diamond Shield':'鑽石盾','Prisoner Gloves':'囚犯手套',
 'Talisman':'護身符','White Ring':'白色戒指','Captain\'s Ring':'隊長戒指','Paralysis Charm':'防麻痺護符','Kraken Claws':'海怪之爪',
 'Sentinel\'s Ring':'哨兵戒指','Sorcerer\'s Scroll':'術士卷軸','Ancient Ring':'古代戒指','Forger\'s Gloves':'鍛造師手套',
 'Monk\'s Charm':'僧侶護符','Dwarven Boots':'矮人靴','Condemned Amulet':'罪人護符','Lothar\'s Ring':'洛薩戒指','Thora Ring':'托拉戒指',
 'Thora Earring':'托拉耳環','Thora Amulet':'托拉護符','Thora Bracelet':'托拉手環','Watcher\'s Charm':'監視者護符',
 'Undead Ring':'不死戒指','Warrior Gloves':'戰士手套','Ninja Boots':'忍者靴','Chimera Claws':'奇美拉之爪','Diamond Ring':'鑽石戒指',
 'Diamond Amulet':'鑽石護符','Condemned Gloves':'罪人手套','Runaway Boots':'逃亡者之靴'},
'Items':{
 'Green Leaf':'綠葉','Green Herb':'綠色藥草','Yellow Leaf':'黃葉','Yellow Herb':'黃色藥草','Mana Tonic':'魔力補藥',
 'Mana Ether':'魔力以太','Mana Potion':'魔力藥水','Mana Elixir':'魔力靈藥','Anti-Poison':'解毒劑','Anti-Blindness':'明目藥',
 'Anti-Silence':'解封藥','Anti-Berserk':'鎮定藥','Anti-Confusion':'清醒藥','Anti-Charm':'破魅藥','Anti-Paralysis':'解麻藥',
 'Bronze Urn':'青銅甕','Silver Urn':'白銀甕','Gold Urn':'黃金甕','Cheese':'乳酪','Bread':'麵包','Cake':'蛋糕',
 'Red Apple':'紅蘋果','Yellow Apple':'黃蘋果','Green Apple':'綠蘋果','Red Shard':'紅色碎片','Blue Shard':'藍色碎片',
 'Yellow Shard':'黃色碎片','Purple Shard':'紫色碎片','Green Shard':'綠色碎片','Grey Shard':'灰色碎片','Black Shard':'黑色碎片',
 'Stone Ore':'石礦','Bronze Ore':'青銅礦','Silver Ore':'白銀礦','Gold Ore':'黃金礦','Holy Flame':'聖焰'},
'States':{'Knockout':'昏迷','Guard':'防禦','Immortal':'不死','Poisoned':'中毒','Blind':'失明','Silenced':'沉默','Berserk':'狂暴','Confusion':'混亂','Charmed':'魅惑','Paralyzed':'麻痺'},
'Enemies':{'Cerberus':'地獄犬','Chimera':'奇美拉','Behemot':'巨獸','Cave Scorpion':'洞窟蠍','Cave Rat':'洞窟鼠','Hell Knight':'地獄騎士',
 'Prisoner':'囚犯','Gang Leader':'幫派首領','Sand Scorpion':'沙蠍','Revenant':'亡魂','Giant Hornet':'巨型黃蜂','Elven Wolf':'精靈狼',
 'Mimic':'寶箱怪','Spectre':'幽靈','Golem':'魔像','Lady Kraken':'海怪女王','Giant Snake':'巨蛇','Remnant':'殘魂','Witch':'女巫',
 'Hell Captain':'地獄隊長','Condemned':'罪人','Prisoner Hound':'囚犯獵犬','Watcher':'監視者','Zombie':'殭屍','Undead Lord':'不死領主',
 'Giant Spider':'巨型蜘蛛','Lizard Soldier':'蜥蜴士兵','Lizard Guard':'蜥蜴守衛','Azael':'阿札爾','Tribe Soldier':'部族士兵',
 'Tribe Magician':'部族法師','Ganga':'岡加'}}

description_exact={
 'Crafted by the Goddess Thora herself.':'由托拉女神親手打造。',
 "Thora's treasure.":'托拉的珍藏。',"Thora's Treasure":'托拉的珍藏。',
 'Sellable.':'可出售。','Restores 30% HP. ONE ALLY.':'恢復一名我方成員 30% 生命值。',
 'Restores 50% HP. ONE ALLY.':'恢復一名我方成員 50% 生命值。',
 'Restores 70% HP. ONE ALLY.':'恢復一名我方成員 70% 生命值。',
 'Restores 100% HP. ONE ALLY.':'恢復一名我方成員全部生命值。',
 'Restores 30% MP. ONE ALLY.':'恢復一名我方成員 30% 魔力。',
 'Restores 50% MP. ONE ALLY.':'恢復一名我方成員 50% 魔力。',
 'Restores 70% MP. ONE ALLY.':'恢復一名我方成員 70% 魔力。',
 'Restores 100% MP. ONE ALLY.':'恢復一名我方成員全部魔力。',
 'Heals 30% HP. ONE ALLY.':'恢復一名我方成員 30% 生命值。',
 'Heals 30% HP. ALL ALLIES.':'恢復全體我方成員 30% 生命值。',
 'Heals 100% HP. ONE ALLY.':'完全恢復一名我方成員的生命值。',
 'Removes status abnormalities. ONE ALLY.':'解除一名我方成員的異常狀態。',
 'Revives ONE ALLY.':'復活一名我方成員。',
 'Magic Damage. Holy Element. ONE ENEMY.':'對一名敵人造成光屬性魔法傷害。',
 'Magic Damage. Holy Element. ALL ENEMIES.':'對全體敵人造成光屬性魔法傷害。',
 'Magic Damage. Dark Element. ONE ENEMY.':'對一名敵人造成暗屬性魔法傷害。',
 'Magic Damage. Dark Element. ALL ENEMIES.':'對全體敵人造成暗屬性魔法傷害。',
 'Magic Damage. Fire Element. ONE ENEMY.':'對一名敵人造成火屬性魔法傷害。',
 'Physical Damage. TWO RANDOM ENEMIES.':'隨機攻擊兩名敵人，造成物理傷害。',
 'Physical Damage. THREE RANDOM ENEMIES.':'隨機攻擊三名敵人，造成物理傷害。',
 'Physical Damage. ALL ENEMIES.':'對全體敵人造成物理傷害。',
 'Physical Damage. Lowers Attack. ONE ENEMY.':'對一名敵人造成物理傷害並降低攻擊力。',
 'Physical Damage. Lowers Defense. ONE ENEMY.':'對一名敵人造成物理傷害並降低防禦力。',
 'Increases Attack. SELF.':'提升自身攻擊力。',
 'Physical Damage. Inflicts Poison. ONE ENEMY.':'對一名敵人造成物理傷害並使其中毒。',
 'Magic Damage. Dark Element. ONE ENEMY.':'對一名敵人造成暗屬性魔法傷害。',
 'Holy Flame used to activate Thora\'s Portal.':'用來啟動托拉傳送門的聖焰。',
}
for pct in (10,20,30):
    description_exact[f'Restores {pct}% HP. ONE ALLY.']=f'恢復一名我方成員 {pct}% 生命值。'
    description_exact[f'Restores {pct}% MP. ONE ALLY.']=f'恢復一名我方成員 {pct}% 魔力。'
for status,zh in [('Poisoned','中毒'),('Blind','失明'),('Silenced','沉默'),('Berserk','狂暴'),('Confused','混亂'),('Charmed','魅惑'),('Paralyzed','麻痺')]:
    description_exact[f'Clears {status} Status. ONE ALLY.']=f'解除一名我方成員的{zh}狀態。'
for pct in (30,50,70):description_exact[f'Clears Knockout restoring {pct}% HP. ONE ALLY.']=f'復活一名我方成員並恢復 {pct}% 生命值。'
for source,zh in [('HP','生命值'),('MP','魔力'),('Attack','攻擊力'),('Defense','防禦力'),('Magic Attack','魔法攻擊'),('Magic Defense','魔法防禦'),('Agility','敏捷')]:
    description_exact[f'Increases maximum {source}.']=f'提升最大{zh}。'

def translate_description(value):
    if not value:return value
    clean=value.strip()
    if clean in description_exact:return description_exact[clean]
    if clean.startswith('Protects against '):
        status=clean.removeprefix('Protects against ').rstrip('.')
        return f'可防止{names["States"].get(status,status)}狀態。'
    # Keep the numeric stat modifiers intact and translate their labels.
    chunks=clean.replace('\n',' ')
    for en,zh in [('M. DEF','魔防'),('DEFM','魔防'),('MDEF','魔防'),('M.ATK','魔攻'),('MATK','魔攻'),('MAT','魔攻'),('ATK','攻擊'),('DEF','防禦'),('AGI','敏捷')]:
        chunks=re.sub(r'\b'+re.escape(en)+r'\b',zh,chunks)
    return chunks

report={}
for kind,mapping in names.items():
    file=data/(kind+'.json')
    arr=json.loads(file.read_text(encoding='utf-8'))
    count=0;unmapped=[]
    for obj in arr:
        if not obj:continue
        name=obj.get('name','')
        if not name or name.startswith('//'):continue
        if name in mapping:obj['name']=mapping[name];count+=1
        elif not re.search(r'[\u4e00-\u9fff]',name):unmapped.append([obj['id'],name])
        if 'description' in obj:obj['description']=translate_description(obj['description'])
    write_json(file,arr)
    report[kind]={'translated_names':count,'unmapped':unmapped}

system_file=data/'System.json'
system=json.loads(system_file.read_text(encoding='utf-8'))
system['terms']['messages'].update({
 'expTotal':'目前%1','expNext':'距下個%1','alwaysDash':'始終奔跑','commandRemember':'記住指令',
 'bgmVolume':'背景音樂音量','bgsVolume':'背景音效音量','meVolume':'演出音樂音量','seVolume':'音效音量',
 'file':'存檔','loadMessage':'讀取哪個存檔？','saveMessage':'儲存到哪個存檔？','possession':'持有數量'})
write_json(system_file,system)

plugins_file=root/'www/js/plugins.js'
plugins=plugins_file.read_text(encoding='utf-8')
for old,new in [('"Option Name":"Fullscreen"','"Option Name":"全螢幕"'),('"Command Name":"Synch Monitor FPS"','"Command Name":"同步螢幕幀率"')]:
    if old not in plugins and new not in plugins:raise RuntimeError(f'Plugin parameter missing: {old}')
    plugins=plugins.replace(old,new)
preserve(plugins_file);plugins_file.write_text(plugins,encoding='utf-8')

windows=root/'www/js/rpg_windows.js'
js=windows.read_text(encoding='utf-8')
old="return value ? 'ON' : 'OFF';"
if old not in js:raise RuntimeError('Boolean text not found')
preserve(windows);windows.write_text(js.replace(old,"return value ? '開' : '關';",1),encoding='utf-8')

difficulty_plugin=root/'www/js/plugins/SSG_DifficultySetting.js'
js=difficulty_plugin.read_text(encoding='utf-8')
old="this.addCommand('Difficulty', 'difficulty');"
if old not in js:raise RuntimeError('Difficulty option not found')
preserve(difficulty_plugin);difficulty_plugin.write_text(js.replace(old,"this.addCommand('難度', 'difficulty');",1),encoding='utf-8')

difficulties=data/'Difficulties.json'
raw=difficulties.read_text(encoding='utf-8')
levels=json.loads(re.sub(r',\s*]',']',raw))
for level in levels:level['name']={'Easy':'簡單','Normal':'普通','Hard':'困難'}.get(level['name'],level['name'])
write_json(difficulties,levels)
print(json.dumps({'backup':str(backup),'report':report},ensure_ascii=True))
