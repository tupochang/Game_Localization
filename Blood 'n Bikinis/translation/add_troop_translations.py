import json
from pathlib import Path
p=Path(__file__).with_name('translation_master.json')
d=json.loads(p.read_text(encoding='utf-8'))
d.update({
'to join my ranks! Come immediately!':'加入我的麾下！立刻過來！',
'The monster has put her inside':'怪物把她關進了',
'a glass bell!':'玻璃罩裡！',
'Yes, exactly!':'沒錯，就是這樣！',
"And it won't let us do what":'而且它不會讓我們',
'we want!':'稱心如意！',
"So it's the moment we run for our lives??":'所以現在該逃命了嗎？？',
"Don't try you can go against my will!":'別妄想違抗我的意志！',
"As I've arrived, to collect my little pets!":'我來接我的小寵物了！',
'You think you can stop me?':'你以為你能阻止我？',
'This mistake will be your downfall!':'你會為這個錯誤付出代價！',
"I'm not a pet... or, if I am,":'我不是寵物……就算我是，',
'then I belong to \\n[1]...':'我也只屬於 \\n[1]……',
'Hahaha, poor lost soul,':'哈哈哈，可憐的迷途靈魂，',
"you're next, after the other two!":'收拾完另外兩個，就輪到你！',
'Laura! You are bestowed with the honor':'蘿拉！你有幸',
'Sandy! You are bestowed with the honor':'珊蒂！你有幸',
'You both are mine, now!':'現在你們兩個都是我的了！',
"And nothing's gonna change that!":'誰都改變不了！',
'Wow that escalated quite quickly!':'哇，事情一下子就失控了！',
'She wanted to join us minutes ago,':'幾分鐘前她還想加入我們，',
"now she's a monster!!":'現在卻變成怪物了！！',
'The hot bitch got contaminated too!':'那個性感女人也被感染了！',
'Time for all the other girls to get revenge,':'其他女孩該趁現在報仇了，',
'I guess!':'我想！',
'Cindy, stupid little slut, showing yourself':'辛蒂，你這個蠢蕩婦，',
"off like that, I'll take care of you!":'還敢那樣招搖，我來收拾你！',
'Help me please,':'救救我，拜託，',
'it hurts so much!':'好痛啊！',
})
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
