"""Hand edited party discussion about seeking medical help."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
5	那現在怎麼辦？到處都是
6	那些該死的怪物！
10	或者找消防員！找軍隊！
13	閉嘴，乾脆打給服飾店好了！
16	聽好了。街上到處都會是
17	那些瘋子。現在
18	沒人有空來照顧我們。
21	這是什麼意思？？
24	我們只能靠自己，而且得戰鬥！
35	免了，你以為那裡會有什麼？
36	醫生和護士正幫忙
37	擊退怪物嗎？
40	說不定那裡有治療方法！
42	蘿拉，你還在那裡念書，
43	對吧？
46	對，可是——
54	別做夢了，那裡大概也
55	跟其他地方一樣被怪物占領。
56	我們還不如去找槍和炸彈！
59	那你上哪裡去找，
60	你這個瘋子？
70	對，這就對了。蘿拉，幫點忙。
71	帶我們去找馬克斯博士。
74	那是誰？
77	我們的院長。
85	嗯，好，我懂了。
89	也許真能在那裡
90	找到有用的東西，比如治療方法。
91	值得一試。
94	要是能幫上辛蒂就好了。
97	她看起來怪怪的，
98	好久沒說過有條理的話了。
104	的確很奇怪。
107	也許她只是累了。
110	所以她才需要
111	醫院的幫忙，各位！
115	牠們已經害了我們其中一人，
116	所以，好吧，值得試試！
119	你剛才不是不想去嗎？
122	我改變主意了！
127	好，沒時間了，走吧！
'''
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[104]
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
