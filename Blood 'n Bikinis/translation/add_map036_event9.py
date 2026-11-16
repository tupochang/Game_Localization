"""Hand edited Alison cage encounter."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
10	走開！！
11	別管我！
14	你他媽到底
15	為什麼會待在籠子裡？！
18	我也不知道，
19	對我來說也沒什麼特別的！
21	不過今天我可不抱怨，
22	籠子救了我一命。
25	\\n[1]，她是艾莉森。
26	她喜歡被人支配。
36	嚴格說來，
37	她算是個奴隸。
40	好了，艾莉森，我們現在
41	放你出來。
44	不要，拜託！
45	放我出去會死的！
48	艾莉森，別怕，
49	這個男人一直在保護我們。
52	我害怕！
55	我們確定艾莉森不是個
56	準備現出原形的怪物？
59	我看她挺像人的。
60	反應也很自然。
63	牠們一開始看起來都很正常！
69	如果她真是怪物，我們還能
70	拿卡琳餵她，哈哈哈！
76	是啊，因為牠吃掉你這把骨頭
77	以後肯定還會餓！
80	抱歉啊，我不夠格
81	當怪物的點心……
92	別鬧了！我不是怪物！
95	聽著，牠們入侵前你就躲進
96	籠子裡，算你走運，
97	但牠們遲早會找到你。
102	我寧願待在這裡。
103	我不會打架！
106	我們也不會！
110	蘿拉，發生什麼事了？
111	你怎麼沒穿衣服？
113	辛蒂怎麼也沒穿？
114	另外那個女孩是誰？？
121	另一個沒穿衣服的女孩是誰？
133	我們沒時間解釋了！
134	艾莉森，要跟就跟，不跟就算了！
137	我要待在裡面。
141	誰都是被逼急了才學會的。
142	拿把刀，隨便拿什麼都好，
143	為自己拚命！
146	好吧，你們可以打開籠子。
147	不過說真的，我比較擅長做家事。
151	這倒不難猜，哈哈。
152	等這一切結束，
153	你來把學校打掃乾淨。
156	樂意之至，我喜歡
157	做家事。現在快讓這一切結束吧，
158	老天爺！我怕死了！
168	所以……這次不是怪物？
177	災難爆發時我已經在籠子裡了。
178	我不是牠們的一員，我保證。
'''
event = loads((root / 'extracted/Data/Map036.rxdata').read_bytes()).attributes['@events'][9]
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
