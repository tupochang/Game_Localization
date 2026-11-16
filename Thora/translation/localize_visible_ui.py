import datetime, json, pathlib, shutil, re

root=pathlib.Path(__file__).resolve().parents[1]
data=root/'www/data'
backup=root/'translation'/('backup_before_ui_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
backup.mkdir()

names={
"Thora's Heart":"托拉之心","Intersection":"交會處","Left Flame Road":"左側聖焰之路","Right Flame Road":"右側聖焰之路",
"The Temple of Light":"光之神殿","Thora's Portal":"托拉的傳送門","Sister's Bedroom":"姊姊的臥室","Temple of Light Exterior":"光之神殿外圍",
"Refugee Cave":"難民洞窟","Hangman's Prison Corridor":"絞刑監獄走廊","Hangman's Prison Cell Block":"絞刑監獄牢區",
"Hangman's Prison Solitary":"絞刑監獄禁閉室","Hangman's Prison Courtyard":"絞刑監獄庭院","Brother's Cell":"兄長的牢房",
"Salma's Basement":"薩爾瑪的地下室","Salma's Cabin":"薩爾瑪的小屋","Clearing":"林間空地","Shrine":"神殿","Shrine Corridor":"神殿走廊",
"Eileen's Hut":"艾琳的小屋","Eileen's Exile":"艾琳的流放地","Woods":"森林","Hunting Ground":"獵場","Elven Village's Entrance":"精靈村入口",
"Luz's Estate":"露茲的莊園","Luz's House":"露茲的家","Luz's Bedroom":"露茲的臥室","Luz's Library":"露茲的書房",
"Sacred Dungeon":"神聖地牢","Sacred Dungeon Entrance":"神聖地牢入口","The Spectral Bridge":"幽靈之橋","Cave Entrance":"洞窟入口","Cave Passage":"洞窟通道",
"Fallharbor":"落潮港","The Skeleton Snake":"骷髏蛇號","Tavern":"酒館","Captain's Den":"船長的住處","Praire of the Dammed":"受詛咒者草原",
"Lighthouse":"燈塔","Lighthouse Interior":"燈塔內部","Lighthouse Upstairs":"燈塔上層","Ashlands":"灰燼之地","Ghost Ruins":"幽靈遺跡",
"Maze Ruins":"迷宮遺跡","Ghost Inn":"幽靈旅店","Interior":"室內","Abyss Prison":"深淵監獄","Abyss Prison Corridor":"深淵監獄走廊",
"Abyss Prison Cell Block B":"深淵監獄 B 區","Abyss Prison Cell Block C":"深淵監獄 C 區","Abyss Prison Cell Block D":"深淵監獄 D 區",
"Abyss Prison Exit":"深淵監獄出口","Camp":"營地","Tent":"帳篷","Burial Site":"墓地","Port of Shadows":"暗影港",
"Private Residence":"民宅","Inn":"旅店","Docks":"碼頭","Docks Blood Island":"血島碼頭","Black Jungle":"黑色叢林",
"Fallen Throne":"墮落王座","Mountain Camp":"山間營地","Demonridge":"惡魔山脊","Demonridge Top":"惡魔山脊頂端",
"Hopeless Dungeon Cell":"絕望地牢牢房","Hopeless Dungeon":"絕望地牢","Fallen Castle Entrance":"墮落城堡入口",
"Fallen Throne":"墮落王座"
}
def map_name(value):
    value=value.strip()
    if value in names:return names[value]
    for prefix,zh in [('Cave ','洞窟 '),('Black Jungle ','黑色叢林 '),('Hopeless Dungeon Cell ','絕望地牢牢房 '),
                      ('Hopeless Dungeon ','絕望地牢 '),('Fallen Castle Stairway ','墮落城堡階梯 '),('Fallen Castle Maze ','墮落城堡迷宮 ')]:
        if value.startswith(prefix) and value[len(prefix):].isdigit():return zh+value[len(prefix):]
    return value

def save_json(file,obj):
    rel=file.relative_to(root)
    dest=backup/rel
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(file,dest)
    file.write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')),encoding='utf-8')

system_path=data/'System.json'
system=json.loads(system_path.read_text(encoding='utf-8'))
system['terms']['basic']=['等級','等級','生命值','生命值','魔力','魔力','TP','TP','經驗值','經驗值']
system['terms']['commands']=[
  '迎戰','逃跑','攻擊','防禦','背包','技能','裝備','狀態','隊形','存檔','結束遊戲','選項',
  '武器','防具','收藏品','裝備','最佳化','清除','新遊戲','繼續遊戲',None,'返回標題','取消',None,'購買','販售']
system['terms']['params']=['最大生命值','最大魔力','攻擊力','防禦力','魔法攻擊','魔法防禦','敏捷','幸運','命中','迴避']
system['armorTypes']=['','一般防具','輕甲','盾牌']
system['equipTypes']=['','武器','盾牌','頭部','身體','飾品']
system['skillTypes']=['','魔法','技能']
system['weaponTypes']=['','劍','斧','書','弓']
system['elements']=['','物理','火','冰','雷','水','土','風','光','暗']
save_json(system_path,system)

actor_names={'Vaynard':'維納德','Garr':'加爾','Salma':'薩爾瑪','Eileen':'艾琳','Luz':'露茲'}
actors_path=data/'Actors.json'
actors=json.loads(actors_path.read_text(encoding='utf-8'))
for actor in actors:
    if actor and actor['name'] in actor_names:actor['name']=actor_names[actor['name']]
save_json(actors_path,actors)
classes_path=data/'Classes.json'
classes=json.loads(classes_path.read_text(encoding='utf-8'))
class_names={'Paladin':'聖騎士','Executioner':'處刑者','Witch':'女巫','Hunter':'獵人','Guardian':'守護者'}
for cls in classes:
    if cls and cls['name'] in class_names:cls['name']=class_names[cls['name']]
save_json(classes_path,classes)

count=0
unmapped=set()
for file in sorted(data.glob('Map[0-9][0-9][0-9].json')):
    obj=json.loads(file.read_text(encoding='utf-8'))
    old=obj.get('displayName','')
    if not old:continue
    new=map_name(old)
    if new==old:unmapped.add(old);continue
    obj['displayName']=new
    save_json(file,obj)
    count+=1
print(json.dumps({'updated_maps':count,'unmapped_map_names':sorted(unmapped),'backup':str(backup)},ensure_ascii=True))
