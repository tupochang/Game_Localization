"""Hand edited Nancy rescue scene."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
12	有人在裡面嗎？
13	開門！
16	……你們是誰？
19	你是南希嗎？
22	對，你們是誰？
25	南希，是我！快出來，
26	我們來救你了。
29	我不能出去。我沒穿衣服。
31	你們能找些衣服，
32	從門縫遞給我嗎？
66	有多亂？
69	不知道，但那地方現在
70	大概快燒光了。
73	我們得快點，還可能有更多怪物
74	跑過來！
77	南希，她說得對，
78	沒時間了。
81	我做不到。
84	你的胸罩穿幾號？
87	我的胸罩尺寸？……
88	39 號，E 罩杯。
91	哇，不錯嘛！
92	蘿拉，把你的比基尼給她。
95	我的比基尼？
98	你的尺寸比較接近，
99	而且她是你朋友。
102	可是我沒有別的衣服了，
103	脫掉就全裸了。
106	說得像你從沒裸露過似的。
107	你在電視廣告裡都敢脫，
108	現在也該習慣了吧。
111	他說得對，你裸露那麼多次，
112	全國的人大概
113	都看過了。
116	可是在這裡脫
117	又不一樣！
118	再說，辛蒂的胸部比我大，
119	她的尺寸明明
120	比較適合南希。
123	南希又不是我朋友。
124	我不想把比基尼給她。
125	我是明星，不拍全裸鏡頭。
128	說真的，辛蒂那套比基尼
129	也遮不了多少啦，哈哈哈！
135	沒什麼。我是說蘿拉現在就該
136	脫下比基尼給南希。
138	剛才不是說了嗎？你在電視上
139	常常這麼做。
146	這不重要。除了我們，
147	附近沒人會看見你。
148	你還不明白情況有多急嗎？
150	我們不能一直等。要嘛
151	照做，要嘛現在就離開。
154	不行！
155	蘿拉，聽他的話！
162	對，沒錯，你得這麼做。
163	快一點。
170	好吧，那……
187	好，南希，我把她的
188	比基尼拿給你，你穿上吧。
209	你看，最後也沒那麼難嘛。
214	我現在有點不好意思。
218	蘿拉，你總不會
219	打算一直
220	這樣待著吧？
226	你沒辦法一邊遮著身體，
227	一邊好好保護自己！
228	好了，別遮了，自然一點。
229	現在有比遮住身體
230	更要緊的事！
233	你確定這樣
234	不會很奇怪嗎？
237	蘿拉，聽我說。
240	\\n[1] 說得對，
241	你得保護自己！
244	……好吧……
249	希望這樣不會
250	太不合適。
255	就這樣，很好。
267	穿得下嗎？
270	還行吧，蘿拉的胸部也太小了——
273	我的尺寸不合你意，真抱歉！
274	你要是不喜歡，
275	就還給我。
287	看來整座城都被包圍了。
288	你的公寓也燒了起來。
290	我們得立刻離開，
291	去找人幫忙！
297	辛蒂！！！
343	（哇。）
346	（第一次看到她這個樣子！）
349	（至少我沒有
350	一個人裸著太久……）
355	我……我不明白……
356	我到底怎麼了……
362	你現在最好緊跟著我，
363	照我說的做！
366	好，我會的。
369	很好。先休息，
370	待在後面。
410	對不起，我不知道那是我的——
413	夠了！
421	可是辛蒂，她是大明星啊！
422	該死！
425	我們根本無力改變這件事，
426	快走吧！
429	（拜託、拜託，讓我們
430	活著逃出這場瘋狂吧！）
432	（就算得一絲不掛地逃出去，
433	也別讓牠們抓到我！）
'''
event = loads((root / 'extracted/Data/Map042.rxdata').read_bytes()).attributes['@events'][1]
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
