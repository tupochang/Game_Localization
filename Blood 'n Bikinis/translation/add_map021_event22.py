"""Hand edited arrival at the school."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
15	就是這裡？
16	培養性感億萬富翁明星的學校？
19	我們也不是個個都成了億萬富翁。
22	有些人成了裸體傳奇！
25	不過，沒錯，
26	這裡曾是我們共同的學校。
33	我知道，對不起。
36	可是我們其他人都在這裡念過書，
37	所以這地方看起來很熟悉，
38	多少有些熟悉……
48	我也不想這樣，可我跟你一樣，
49	大家也都認識我。
52	是啊，大家都知道你愛露，
53	沒錯。
56	可我根本不是那樣的人！
58	而且我跟你們在一起時
59	已經光著身子很久了……
62	那你早該習慣了。
63	沒什麼好說的。
71	對啊，她應該把這
72	當作練習！
75	可那原本是我的比基尼。
78	原本「是」。
79	現在是我的了。
82	你穿起來根本不合身。
85	我不想再忍受
86	你那些尖酸刻薄的話。
88	這一切都不關你的事。
110	好了，女孩們，我們走吧。
115	蘿拉，還有其他人，你們覺得
116	老師和學生會先去哪裡？
119	很難說。
120	如果他們還活著，大概往樓上去了。
121	換作我也會這麼做。
124	總共幾層樓？
127	嗯……
130	三層。
'''
event = loads((root / 'extracted/Data/Map021.rxdata').read_bytes()).attributes['@events'][22]
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
