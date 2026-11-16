import datetime, json, pathlib, re, shutil

root=pathlib.Path(__file__).resolve().parents[1]
data=root/'www/data'
backup=root/'translation'/('backup_before_text_polish_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
backup.mkdir()
def save(file,obj):
    dest=backup/file.relative_to(root)
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(file,dest)
    file.write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')),encoding='utf-8')

weapon_prose={
2:'一般的戰鬥用劍。',3:'獸人打造來獵殺食人魔的劍，沉重卻威力強大。',4:'沃爾斯曾用過的劍。',5:'以龍鱗鍛造的劍。',
11:'只有矮人才能揮動。',12:'真正的矮人武器。',13:'雖然不像斧頭，砍起來一樣痛。',14:'威力強大，但重量會拖慢使用者。',
15:'曾由地獄隊長持用。',20:'基礎卻可靠的魔法書。',21:'記載了稍進階的法術。',22:'詳細記載黑魔法的奧祕。',
23:'古老得彷彿與時間同壽。',29:'泰林愛用的武器。',30:'製作精良的長弓。',31:'似乎是為某位主人量身打造。',32:'雖然稍短，卻十分致命。'}
armor_prose={
2:'簡單的戰鬥護甲。',3:'十分堅固，但會拖慢腳步。',4:'軍隊的制式鎧甲。',5:'意外地適合人類穿著。',8:'阿札爾穿過的鎧甲。',
10:'不算耐用，但還能提供保護。',11:'軍隊使用的制式頭盔。',12:'純石製成，保護力強但非常沉重。',13:'看來大家的頭圍都差不多。',
19:'舒適又耐用。',20:'對非獸人來說有點大，但仍能提供良好保護。',21:'布料柔軟，卻相當堅韌。',22:'軍隊的制式背心。',
23:'長度略短，保護力仍然不錯。',28:'護住耳朵，也讓你看起來很時髦！',29:'金屬護片提供有效保護。',
30:'看來大家的頭圍都差不多。',37:'總比徒手格擋好。',38:'軍隊使用的制式盾牌。',39:'做工精美，似乎帶有魔力！',
40:'只要握得穩，什麼都擋得住。',41:'堅固的火山石盾。'}
for kind,prose in [('Weapons',weapon_prose),('Armors',armor_prose)]:
    file=data/(kind+'.json')
    arr=json.loads(file.read_text(encoding='utf-8'))
    for obj in arr:
        if not obj or not obj.get('description'):continue
        desc=obj['description']
        if kind=='Armors':
            for en,zh in [('Poison','中毒'),('Paralysis','麻痺'),('Blindness','失明')]:desc=desc.replace(en,zh)
        if obj['id'] in prose:
            mod=re.search(r'((?:攻擊|敏捷|魔攻|防禦|魔防)\s*[+-]\s*\d+.*)$',desc)
            desc=prose[obj['id']]+(' '+mod.group(1) if mod else '')
        desc=desc.replace("Thora's treasure.",'托拉的珍藏。')
        obj['description']=desc
    save(file,arr)

system_file=data/'System.json'
system=json.loads(system_file.read_text(encoding='utf-8'))
messages={
'actionFailure':'對%1沒有效果！','actorDamage':'%1受到%2點傷害！','actorDrain':'%1被吸取了%2點%3！',
'actorGain':'%1獲得%2點%3！','actorLoss':'%1失去%2點%3！','actorNoDamage':'%1沒有受到傷害！',
'actorNoHit':'沒打中！%1沒有受到傷害！','actorRecovery':'%1恢復了%2點%3！',
'buffAdd':'%1的%2提升了！','buffRemove':'%1的%2恢復正常！','counterAttack':'%1發動反擊！',
'criticalToActor':'猛烈的一擊！！','criticalToEnemy':'漂亮的一擊！！','debuffAdd':'%1的%2下降了！',
'defeat':'%1戰敗了。','emerge':'%1出現了！','enemyDamage':'%1受到%2點傷害！',
'enemyDrain':'%1被吸取了%2點%3！','enemyGain':'%1獲得%2點%3！','enemyLoss':'%1失去%2點%3！',
'enemyNoDamage':'%1沒有受到傷害！','enemyNoHit':'沒打中！%1沒有受到傷害！','enemyRecovery':'%1恢復了%2點%3！',
'escapeFailure':'然而，逃跑失敗了！','escapeStart':'%1開始逃跑！','evasion':'%1躲開了攻擊！',
'levelUp':'%1升至%2%3！','magicEvasion':'%1抵消了魔法！','magicReflection':'%1反彈了魔法！',
'obtainExp':'獲得%1%2！','obtainGold':'獲得\\G%1！','obtainItem':'獲得%1！','obtainSkill':'學會%1！',
'partyName':'%1的隊伍','preemptive':'%1搶得先機！','substitute':'%1保護了%2！','surprise':'%1受到了突襲！',
'useItem':'%1使用了%2！','victory':'%1獲得勝利！'}
system['terms']['messages'].update(messages)
save(system_file,system)
print(json.dumps({'backup':str(backup),'battle_messages':len(messages)},ensure_ascii=True))
