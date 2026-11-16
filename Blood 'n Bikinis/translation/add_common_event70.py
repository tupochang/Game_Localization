"""Hand edited companion gift dialogue."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
3	謝謝，這份禮物真好。
4	我從沒想過你會注意到我……
7	我怎麼會注意不到？
10	不知道。這裡很多女孩
11	都比我豐滿。
14	別擔心，我只想找個
15	胸部剛好握得住的女孩。
22	你不用這麼多話，
23	收下禮物就對了！
41	你確定要這麼做？
44	當然確定。
45	對我而言，你最好了。
48	你最喜歡我哪一點？
51	全部。
52	每一處都……這麼豐滿。
70	這是給我的？
71	像迪士尼公主那樣？
74	對，因為你不只是明星，
75	對我來說也是公主！
78	可是我連另一個都沒有。
81	心意才重要，
82	小辛蒂。
85	可是這樣我就沒辦法戴了。
88	收下禮物就好！
106	喔，謝謝你！
107	如果另一個也有，
108	參加名流派對就派得上用場了。
111	等這一切結束，再給你另一個。
114	好啊！我要點香檳，
115	還有好幾公升的莫希托慶祝！
136	給我的？
139	看來是。
142	謝謝，可是……
143	尺寸真的適合我嗎？
146	誰在乎？
147	這是禮物。
170	嘿嘿！
171	原來你也有心軟的時候嘛！
174	先別擺出小賤人的樣子。
177	我說中你的心事了？
204	你瘋了，居然把這個送我。
207	我才不在乎
208	別人怎麼說。
211	可是之後我會
212	受到重罰。
215	等這一切結束，你就跟我走。
218	（天啊，他真的瘋了！）
236	我的腳可沒這麼小。
239	我知道，你哪裡都不小。
242	也許只有腦袋小？
'''
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[70]
commands = event.attributes['@list']
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
