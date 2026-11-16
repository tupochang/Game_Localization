"""Hand edited first aid and Karine dialogue."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
3	這裡有急救箱！
4	我們可以清理傷口，
5	再包紮一下。
8	太好了！
9	你怎麼知道這裡有？
12	沒什麼，男主管們都想
13	跟我上床，我才有點特權。
15	\\n[1]，拿著，
16	也分一些給其他人！
24	真管用。
25	我現在好多了。
29	\\n[1]？
32	嗯，有何不可？
33	我覺得她長得挺好看。
36	那一定是你
37	不夠了解她，或是
38	根本沒留意。
43	你說什麼？
46	那就讓他看看。
59	等一下。
60	卡琳，我給你下過命令。
63	像這樣……
67	……這樣嗎？
68	你要的是這樣？
71	再多一點。
73	得讓 \\n[1] 看清楚，
74	不然他還是不明白。
79	這樣？
80	現在乳頭都露出來了。
90	你還想要更多？
93	對，讓你那小小的乳頭
94	一直露給大家看。
99	好吧，可是……
104	……再往下拉，
105	我就要失去上衣了……
113	對不起，伊莎貝爾，
114	我沒達到你的標準。
124	哼，居然這樣護著她，
125	真可悲！
128	（謝謝你……雖然我
129	不配得到這樣的支持……）
141	嘿嘿，我就知道你會同意！
'''
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[284]
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
