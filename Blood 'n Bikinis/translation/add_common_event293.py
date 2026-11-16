"""Hand edited arrival at the supposed shelter."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
2	我們被騙了！
3	這根本不是避難所！
6	這裡停了那麼多吉普車和卡車，
7	看起來就是軍方的地方！
10	還有那架巨大的直升機。
13	可他們為什麼攻擊我們？！
14	我們又沒對他們做什麼！
17	或許是上頭有人
18	出賣了我們！
21	政府？你是說
22	政府出賣我們？？
25	我們可能被人「賣」了。
33	我們會全死在這裡嗎？
36	不會，蘿拉，只要我們
37	控制這個地方。
45	我不想死！
46	我的粉絲會怎麼想？
57	到時候就能輕易把這裡
58	變成堡壘，讓那些該死的殭屍
59	一個也攻不進來！
65	還能找到衣服！
66	我都不記得自己
67	裸著多久了！
87	這樣不會太危險嗎？
92	對，別管那個說謊的混蛋！
95	可是我們該怎麼辦？
98	就算要死，我也不想這樣死！
101	不，珊蒂說得對，我們四處看看。
107	我現在好冷。
108	我又緊張又擔心，
109	都快哭出來了。
112	你從來不問我還好不好！
115	安靜一點。
127	你認真的？
128	她心情怎麼樣關我屁事！
146	我也只是像辛蒂一樣覺得冷。
147	這地方簡直像冰箱。
158	我只是覺得冷。
162	這對我們真的很難熬。
167	我的衣服還在伊莎貝爾手裡，
168	可她不肯還我。
171	你們這群沒穿衣服的別再抱怨了！
172	一件小小的比基尼
173	也暖和不到哪裡去！
175	我也冷，大家都冷，
176	我也累了，也受夠了！
179	我們得給你們弄點——
'''
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[293]
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
