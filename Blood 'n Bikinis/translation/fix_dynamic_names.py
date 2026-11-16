import json
from pathlib import Path
p=Path(__file__).with_name('translation_master.json')
d=json.loads(p.read_text(encoding='utf-8'))
d.update({
'\\n[1] gets +50 EXP per battle for each':'隊伍中每多一名沒穿衣服的女孩，\\n[1]',
'\\n[1] and  \\i[295] get their LEVEL ':'\\n[1] 與 \\i[295] 迷幻時，每回合',
'multi-hits and follow a skill from \\n[1].':'也無法跟隨 \\n[1] 的技能連攜。',
'may follow up on a skill from \\n[1].':'能跟隨 \\n[1] 發動技能。',
'Listen to \\n[1] instead of whining':'別再哭鬧了，聽聽 \\n[1] 的話，',
'And \\n[1], if he wanted to lust':'就算 \\n[1] 想找個漂亮女人',
'naked girl in the party.':'每戰就多獲得 50 經驗值。',
})
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
