"""Hand edited dispute over Karine's clothes."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
5	天啊，我現在才想到！
18	可是為什麼？
19	我做錯什麼了？
22	你是闖進來的！
23	一個腦袋空空的金髮闖入者！
26	我不明白。
38	要她那樣做，對你有什麼好處？
42	對我沒好處。但蘿拉和辛蒂
43	都是這所學校的正式成員，
44	卻得光著身子，而這個……
47	伊莎，冷靜點，
48	你太激動了。
57	其實也沒那麼糟。
58	我是說，我有點習慣了。
59	只有一點。
62	你之前還一直為了
63	「你的」比基尼跟我吵！
85	卡琳本來就不該在這裡，
86	所以她得把衣服交出來。
117	真的？你確定？
120	照做，笨女孩。
128	別一天到晚道歉，
129	動動腦筋，傻瓜！
153	你看，蘿拉，以後就不會
154	只有你一個人這樣了。
155	對你來說不是很好嗎！
160	我不能穿她的比基尼嗎？
163	不可能。你看看
164	卡琳，她胸部平得像塊板，
165	幾乎像男人。
169	你的胸部會被她那件
170	小比基尼擠扁的！
173	聽起來也沒那麼糟。
174	我願意試試。
177	我說了不行。
178	卡琳，你覺得呢？
'''
event = loads((root / 'extracted/Data/Map039.rxdata').read_bytes()).attributes['@events'][15]
commands = event.attributes['@pages'][0].attributes['@list']
p = root / 'translation_master.json'
dictionary = json.loads(p.read_text(encoding='utf-8'))
for line in data.strip().splitlines():
    number, translation = line.split('\t', 1)
    command = commands[int(number)].attributes
    assert command['@code'] in (101, 401)
    raw = command['@parameters'][0]
    original = raw.decode('cp932') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
    if original in dictionary:
        continue
    dictionary[original] = translation
p.write_text(json.dumps(dictionary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
