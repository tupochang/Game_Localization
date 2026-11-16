import json
from pathlib import Path
p=Path(__file__).with_name('translation_master.json')
d=json.loads(p.read_text(encoding='utf-8'))
d.update({
"  \\w[114] \\c[6]BLOOD 'N BIKINIS DEVELOPED BY\\c[0]  \\w[115]":"  \\w[114] \\c[6]《Blood 'n Bikinis》製作團隊\\c[0]  \\w[115]",
'\\c[6]SCR34MER\\c[0] (MAIN IDEA AND STORY)':'\\c[6]SCR34MER\\c[0]（原案與劇情）',
'\\c[6]KAZAAR\\c[0] (LEVELS)':'\\c[6]KAZAAR\\c[0]（關卡）',
'\\c[6]PICO\\c[0] (GAMEPLAY AND TESTING)':'\\c[6]PICO\\c[0]（玩法與測試）',
'  \\w[112] \\c[6]WORLDS GFX\\c[0]  \\w[113]':'  \\w[112] \\c[6]場景美術\\c[0]  \\w[113]',
'  \\w[116] \\c[6]MONSTERS GFX\\c[0]  \\w[122]':'  \\w[116] \\c[6]怪物美術\\c[0]  \\w[122]',
'  \\w[117] \\c[6]SPRITES GFX\\c[0]  \\w[117]':'  \\w[117] \\c[6]角色圖塊\\c[0]  \\w[117]',
'  \\w[118] \\c[6]CHARACTERS GFX\\c[0]  \\w[115]':'  \\w[118] \\c[6]人物美術\\c[0]  \\w[115]',
'  \\w[123] \\c[6]ICONS GFX\\c[0]  \\w[115]':'  \\w[123] \\c[6]圖示美術\\c[0]  \\w[115]',
'  \\w[124] \\c[6]ANIMATIONS FX\\c[0]  \\w[125]':'  \\w[124] \\c[6]動畫特效\\c[0]  \\w[125]',
'  \\w[119] \\c[6]MUSIC\\c[0]  \\w[121]':'  \\w[119] \\c[6]音樂\\c[0]  \\w[121]',
'  \\w[120] \\c[6]SOUNDS\\c[0]  \\w[121]':'  \\w[120] \\c[6]音效\\c[0]  \\w[121]',
'(LEATHERFACE SPRITE, BLACKHAWK':'（皮臉角色圖、黑鷹',
'MASK: KAZZADOR)':'面具：KAZZADOR）',
'(TANK SPRITE: NOWEL)':'（坦克角色圖：NOWEL）',
'(FIRE ANIMATION, TANK EXPLOSION:':'（火焰動畫、坦克爆炸：',
'WRATH GAMES STUDIO)':'WRATH GAMES STUDIO）',
})
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
