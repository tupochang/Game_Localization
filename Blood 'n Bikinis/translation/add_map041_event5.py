"""Hand edited the transformed dean encounter."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
3	你是說這東西
4	就是你們的馬克斯博士？院長？
7	那……是他的衣服……
8	可是他看起來……不一樣了。
11	謝啦，福爾摩斯。要是你的
12	腦袋跟胸部一樣大就好了！
15	唔，別說了。
16	我已經盡力了。
24	牠們怎麼沒像吃掉其他人那樣——
31	等等！他動了！
32	那個混蛋真的動了！
33	蘿拉，試著跟他說話。也許
34	在一切都太遲之前，
35	我們還能問出些什麼！
38	可是我害怕！
41	你認識他，就跟他說話啊！
44	快點，蘿拉！
47	好啦，別大家一起對我吼。
81	他要我鑽到桌子底下，
82	你們要我怎麼辦？
94	你確定？好吧。
115	辛蒂，過來這裡，
116	趁蘿拉還在忙。
119	為什麼要我
120	過去你旁邊？
123	過來就對了，別問。
124	陪我一下。
138	哇，世界級流行巨星辛蒂
139	竟然在做這種事！真希望我有相機！
141	只要我能活著逃出去，
142	肯定能靠照片大賺一筆！
171	我問完了。他倒是肯配合。
172	只是……根本沒有逃生的方法。
175	搞什麼！費了那麼多勁
176	讓他開口，結果就
177	問出這種答案？！
180	我也不知道，是你們要我
181	跟他說話的！
184	他跟你說了什麼？
187	我不知道……
188	我們全都會死。
190	然後他就死了。希望不是我害的，
191	我應該沒做錯什麼吧。
194	不，我們不會死！
207	喔，謝謝，我剛才真的很不確定——
231	我們殺了馬克斯博士！
234	蘿拉，動動腦子！
235	那東西想侵犯你！
238	我都沒發現！
239	你又救了我一次！
246	拜託，我們現在離開這裡吧。
247	我覺得不太舒服！
250	我沒意見。
'''
event = loads((root / 'extracted/Data/Map041.rxdata').read_bytes()).attributes['@events'][5]
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
