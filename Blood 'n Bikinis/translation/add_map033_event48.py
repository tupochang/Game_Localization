"""Hand edited final sacrifice decision dialogue."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
11	你認真的？
17	你就讓他這麼做？
20	這是為了大家好。
21	會很痛，但只要
22	幾秒鐘就結束了。
25	好吧，我想沒人會願意為了
26	一個愚蠢又順從的女孩
27	挺身而出……
29	能不能先開槍打死我，
30	再把我扔進那台機器？
33	不行，你得活著進去。
36	天啊！
39	對不起，蘿拉。
42	時間緊迫，我們
43	沒空再拖了。
46	所以接下來會怎樣？
49	走進那台機器。
50	我們一按下按鈕，
51	幾秒鐘內你就會被打成肉泥。
58	珊蒂。
61	不，抱歉，絕對不行。
64	這裡由沃里克指揮。
67	我才不管！
68	我可是重要人物，
69	為美國效力！
72	我明白。
73	\\n[1]，抱歉，我願意代替她。
78	辛蒂。
81	你在開玩笑嗎？
82	我是大明星，怎麼能被拿去獻祭？
85	這裡由沃里克指揮。
88	沃里克是誰？
91	我是說，\\n[1]。
99	她說得對。
100	\\n[1]，抱歉，我去吧。
109	伊莎？
112	你說真的？
117	在這座避難所裡，
118	我們都該服從沃里克的命令。
121	沃什麼克，我才不在乎。
122	卡琳是我的奴隸，
123	她要代替我進去。
128	會很痛嗎？
131	會，但不會太久。
139	卡琳。
142	你想要我去死？
145	總得有人去。對不起。
154	那就再見了。
159	艾莉森。
162	我沒有別的選擇嗎？
165	沒有。
168	那我也無能為力了，對吧？
174	我就知道會落到這個下場。
175	你們打算怎麼獻祭我？
178	你自己走進去，或由我們把你
179	放進絞碎機，然後你會變成肉泥。
182	拜託，你代替我去吧。
185	最後還是由 \\n[1] 決定。
190	好吧，奧蘭琪，就由你去。
193	我明白你的選擇。
194	現在我會走進絞碎機。
196	機器會把我絞成肉泥，收集
197	我的血。接下來儀式會自動進行。
199	這一切結束後，
200	記得啟動核彈頭。
209	那我去吧。
210	這是我的命運，也對其他人公平。
213	獻祭選項：
214	蘿拉－艾莉森－卡琳－奧蘭琪
'''
event = loads((root / 'extracted/Data/Map033.rxdata').read_bytes()).attributes['@events'][48]
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
