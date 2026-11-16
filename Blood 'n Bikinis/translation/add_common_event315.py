"""Hand edited Sandy's weighing scale follow-up."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
2	啊，珊蒂，來看看你的體重
3	有沒有變化。
26	大概沒變，頂多
27	差個幾百克。
38	我已經說過不要了。
41	我會在正式工作人員面前量，
42	但你又不是。
43	這讓我有點不自在。
46	對你來說，
47	我和別的男人有什麼差別？
49	這樣兩套標準
50	也太奇怪了。
71	……好吧。
72	隨你。
83	我還是五十四公斤，跟上次一樣。
87	現在我確定這才是你的真實體重。
90	（她的胸部真難看，
91	垂得跟老太太一樣！）
107	那我的「真實」體重讓你吃驚嗎？
123	那不重要，別在意他們。
126	而我還有曬痕呢。
137	現在可以把比基尼還我嗎？
140	不用，你可以繼續這樣。
144	你想要我這樣？
154	我希望自己有那個膽量，
155	但老實說，我還是想穿回比基尼。
165	你總不想再有另一個人
166	像蘿拉一樣四處走吧！
173	嗯，好吧。
190	我覺得這樣比較好。
200	我滿身都是血，
201	抱歉，現在不是量體重的時候！
'''
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[315]
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
