"""Hand edited the search for survivors at McDom."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
3	看看這血淋淋的一片狼藉！
6	管理員不見了！
9	我跟你說，他們這是
10	罪有應得！
13	還有別的樓層嗎？
16	再往上一層，樓梯在右邊。
19	我們得去看看！
20	說不定還有倖存者！
23	要是老想著找倖存者，
24	我們自己也活不了多久！
27	聽我說，光是逃跑
28	解決不了問題。
31	我同意。卡琳，你走前面，
32	替我們開路！
35	大家最好待在一起！
38	我才不要拿自己的命冒險！
39	讓醜八怪卡琳先走！
43	我早就說了，我覺得
44	她長得還不錯。
48	醜？我覺得她挺好看的！
53	你他媽眼睛有問題嗎？
54	她平得跟男孩子一樣！
60	我還是喜歡你的樣子。
63	……謝謝……很少有人
64	這樣稱讚我。
67	那當然有原因，笨蛋！
70	可是她替我挑的衣服
71	太緊了，看起來更平。
74	別再抱怨了！
82	我突然想到……
83	麥當姆餐廳裡怎麼會穿比基尼？
86	喔，他們辦了比基尼活動，
87	所有收銀員都得穿。
88	她也一樣！
90	福爾摩斯，你自己也沒穿
91	普拉達西裝啊？
94	事情發生時，
95	我們正在游泳池。
98	喔，那真不是時候！
101	是啊，對大家都不是時候。
102	不過現在我們在一起，
103	一定撐得過去！
108	沒錯！我現在就想要一個
109	膽子夠大的男人！
'''
event = loads((root / 'extracted/Data/Map024.rxdata').read_bytes()).attributes['@events'][13]
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
