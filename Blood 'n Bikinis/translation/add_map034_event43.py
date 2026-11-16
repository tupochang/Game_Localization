"""Hand edited descent into the bunker laboratory."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
3	天啊，這裡發生了什麼事？
6	上次來時還不是這樣。
9	上次是多久以前？
12	也許一個星期前？
13	勞倫斯大人不喜歡我來這裡。
16	我們回樓上吧，我敢肯定
17	在這裡找不到什麼好東西！
21	她可能說得對，這地方
22	空氣難聞，我可不想死！
28	我也不想。我還有演藝事業，
29	還有我的粉絲！他們怎麼辦？！
34	先冷靜一下！
35	都給我冷靜！
37	奧蘭琪，你多少知道
38	發生了什麼事吧？！
48	有沒有可能是某個實驗
49	失控了？
52	對，有……有可能。
55	那我們可就糟了。
56	先是背叛，現在又是這樣。
57	兩件事也許有關。
60	那你覺得我們該怎麼辦？
63	離開這裡！
66	我同意，快離開！
67	再這樣吵下去，牠們就會像她說的，
68	吃掉我們，或讓我們懷上怪物！
72	我不想懷上怪物。
73	我也不想被任何一隻
74	怪物抓住！
79	可我們知道，樓上也好，外面也好，
80	哪裡都沒有救援。我們得往深處找。
82	奧蘭琪，你記得
83	最底層有什麼嗎？
86	那裡是……實驗室的核心區域。
87	嚴禁進入。
90	現在不管那些了，走吧！
'''
event = loads((root / 'extracted/Data/Map034.rxdata').read_bytes()).attributes['@events'][43]
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
