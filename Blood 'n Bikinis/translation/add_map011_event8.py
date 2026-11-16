"""Hand edited Cindy's house and money conversation."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
4	你知道她把錢
5	放在哪裡嗎？
11	拜託，她可是億萬富翁！
14	抱歉，我不能縱容
15	這種事。
18	我知道她是你朋友，可你
19	似乎不明白她有多不在乎那點錢。
23	我不想再談這個了。
31	你跟珊蒂熟嗎？
34	不算熟……
37	那蘿拉呢？
40	比較熟一點。
43	我們去找那輛車，
44	離開這裡吧。
47	能不能找支手機？
48	我想跟我的經紀人說話。
51	辛蒂，現在最重要的
52	是找個安全的地方。
55	你確定嗎？
67	原來這是你家。你這個有錢人
68	住的地方，我還以為會更氣派。
71	我有好幾棟房子。
74	你的錢放在哪裡？
77	沒放在特別的地方，怎麼了？
80	我想拿一些。眼下這種情況，
81	天知道我們會不會需要錢。
85	你想要多少？
88	保險起見，
89	把你有的全給我。
92	可我放在這裡的不多。
95	別謙虛了。
96	到底有多少？
99	我不知道，得先去看看。
102	嘖，你這個億萬富翁
103	倒真不愛炫耀。
106	抱歉。等我能拿到錢，
107	就給你一些。
110	這還差不多。
111	我要……
116	好，等我們脫離險境，
117	我就給你。
120	好，先把這裡有的給我，
121	總比沒有好。
128	那真的很多耶。
131	對你來說只是小錢。
134	好吧，你想要的話我會給，
135	不過要等之後……
138	我會記得。先把這裡
139	有的錢給我。
140	就當作一點訂金吧。
147	不行，我做不到，這太多了。
150	拜託，對你來說只是小錢。
153	我們在這裡找到多少，我就給你多少。
154	現在該走了。
159	你瘋了嗎？！
162	現在該走了。
'''
event = loads((root / 'extracted/Data/Map011.rxdata').read_bytes()).attributes['@events'][8]
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
