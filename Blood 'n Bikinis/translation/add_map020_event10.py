"""Hand edited meeting Isa in the building."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
36	到這邊來，
37	快過來！
41	你在這裡待多久了？！
44	你怎麼不設法逃走？！
47	你腦袋不靈光嗎？
50	快到另一邊來，
51	幫幫我們！
54	我認識她，她也是
55	我們學校的學生！
58	早該想到，胸部大的女孩
59	全都來自你們學校！
65	也可以這麼說。
69	我叫 \\n[1]。
72	我是伊莎貝爾，大家都叫我伊莎。
74	我沒辦法再擋住這群怪物多久了！
75	少聊兩句，快來幫我！
78	她是誰？
81	她是卡琳。
82	快幫我宰了那些混蛋！
91	好，但我們得邊打邊走。
94	太好了！總算來了！！！
97	樓上還有
98	倖存者嗎？
101	不知道，管理員們上去
102	已經好一陣子了！
105	我們得去看看。
108	蘿拉、珊蒂，留在這裡別動，
109	隨便拿點東西防身。
122	你認真的？
123	我不想待在這裡，
124	我要跟你一起去！！
127	你們都需要休息，
128	不然會累垮的。
129	珊蒂，你也是！
132	我可是奧運冠軍，
133	哪有那麼容易倒下！
142	卡琳，過來！
145	好，當然。
232	那個沒穿衣服的是歌手辛蒂嗎？
233	旁邊那個又是誰？
236	對，她是辛蒂，另一個是蘿拉。
239	辛蒂竟然沒穿衣服！要是我有相機，
240	就能拍幾張賣給狗仔隊了！
243	小姑娘，你現在最該祈求的
244	是活下去。
266	那個沒穿衣服的笨蛋是誰？
269	誰，蘿拉嗎？
270	別這樣說她。
273	她要不是笨蛋，為什麼
274	要一絲不掛地到處跑？
277	看來你沒看過她
278	工作的樣子。
279	總之我們該走了，別再閒聊。
'''
event = loads((root / 'extracted/Data/Map020.rxdata').read_bytes()).attributes['@events'][10]
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
