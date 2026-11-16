import json
from pathlib import Path
p=Path(__file__).with_name('translation_master.json')
d=json.loads(p.read_text(encoding='utf-8'))
for en,zh in {'LAURA':'蘿拉','SANDY':'珊蒂','CINDY':'辛蒂','NANCY':'南希','ISA':'伊莎','KARINE':'卡琳','ALISON':'艾莉森','ORANGE':'奧蘭潔'}.items():
    d[f'      {en} SEDUCTION AVAILABILITY']=f'      {zh}的誘惑接受度'
    d[f'      {en} TEASING AVAILABILITY']=f'      {zh}的挑逗接受度'
for en,zh in {'HERO':'主角','LAURA':'蘿拉','SANDY':'珊蒂','CINDY':'辛蒂'}.items():
    turns={'HERO':5,'LAURA':2,'SANDY':2,'CINDY':3}[en]
    d[f'ﾂｷ {en}: {turns} turns']=f'・{zh}：{turns} 回合'
for icon,turns in [(294,4),(295,4),(296,1),(297,4),(298,3)]:
    d[f'ﾂｷ \\i[{icon}]: {turns} {"turn" if turns==1 else "turns"}']=f'・\\i[{icon}]：{turns} 回合'
d.update({
'\\c[4]MULTI-SPARE!\\c[0]  \\i[187] \\i[187] \\i[187]':'\\c[4]多重饒恕！\\c[0]  \\i[187] \\i[187] \\i[187]',
'\\c[4]DOUBLE-SPARE!\\c[0]  \\i[187] \\i[187]':'\\c[4]雙重饒恕！\\c[0]  \\i[187] \\i[187]',
'\\c[4]SPARE!\\c[0]  \\i[187]':'\\c[4]饒恕！\\c[0]  \\i[187]',
'\\c[3]MULTI-STRIKE!\\c[0]  \\i[186] \\i[186] \\i[186]':'\\c[3]多重重擊！\\c[0]  \\i[186] \\i[186] \\i[186]',
'\\c[3]DOUBLE-STRIKE!\\c[0]  \\i[186] \\i[186]':'\\c[3]雙重重擊！\\c[0]  \\i[186] \\i[186]',
'\\c[3]STRIKE!\\c[0]  \\i[186]':'\\c[3]重擊！\\c[0]  \\i[186]',
'+15 LIFE, +10 NRG':'+15 生命、+10 能量',
'+12 LIFE, +7 NRG':'+12 生命、+7 能量',
'+10 LIFE, +5 NRG':'+10 生命、+5 能量',
'+75 LIFE, +40 NRG':'+75 生命、+40 能量',
'+35 LIFE, +22 NRG':'+35 生命、+22 能量',
'+15 LIFE, +12 NRG':'+15 生命、+12 能量',
'+7 LIFE +1 NRG ':'+7 生命 +1 能量 ',
'+5 LIFE +3 NRG ':'+5 生命 +3 能量 ',
'+3 LIFE +4 NRG ':'+3 生命 +4 能量 ',
'+4 LIFE +5 NRG +69 EXP':'+4 生命 +5 能量 +69 經驗',
'+10 NRG +99 EXP':'+10 能量 +99 經驗',
'(Stetoscope boost for Laura)':'（蘿拉的聽診器加成）',
'(Iphone boost for Sandy)':'（珊蒂的手機加成）',
'(Iphone boost for Cindy)':'（辛蒂的手機加成）',
'(Microphone boost for Cindy)':'（辛蒂的麥克風加成）',
'(Handcuffs boost for Karine)':'（卡琳的手銬加成）',
'AUTO-SAVED!':'已自動儲存！',
})
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
