"""Hand edited Melanie encounter and the decision to see the dean."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
2	救救我，我想回
3	學校！
6	我認識這個女孩！
7	她是梅蘭妮，
8	也是我們學校的！
11	天啊，蘿拉，你誰都認識。
14	我常參加學校活動，
15	也做很多志工服務。
18	我倒不意外。
21	拜託救救我！
24	（她也挺漂亮的。）
25	當然，跟我們走！
28	可是我不能……
31	梅蘭妮，為什麼？
34	喔，蘿拉……
35	你看起來真是美味極了！
41	要嘛她突然對女人
42	熱情高漲，要嘛就是正在變異！
45	我猜是第二種！
81	我……我他媽怎麼知道？！
84	我全身都被咬了！
85	我一定被感染了！
86	我完蛋了！
89	不，還沒有！
90	你根本不知道感染是怎麼回事，
91	誰都不知道！
94	不是的，我真的完蛋了！
97	那隨便你，想死就
98	留在這裡等死！
101	當然不想，誰會想死！
105	看看這裡！
107	辛蒂！
108	她還好端端地跟著我們！
111	拜託，她算什麼好例子？
112	老兄，她一直光著身子，
113	看起來也完全不在意！
116	那你到底要怎樣？！
119	有人叫我嗎？……
124	我們全都會死！
125	這是事實，大家心裡都明白！
128	\\n[1]，拜託保護我！
129	別丟下我，求你了！
132	全都給我閉嘴！
133	總得有人知道
134	究竟發生了什麼事。
136	也許那位院長知道。
137	蘿拉，帶我們去找他！
139	振作一點，
140	帶我們過去！
'''
event = loads((root / 'extracted/Data/Map040.rxdata').read_bytes()).attributes['@events'][23]
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
