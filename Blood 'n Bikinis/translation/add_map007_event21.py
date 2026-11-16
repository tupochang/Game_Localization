"""Hand edited weighing scale conversations."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
0:14	我想知道。
0:26	一百二十四。
0:29	那是穿著比基尼量的。
0:31	你應該脫掉再量一次，
0:32	才知道確切體重。
0:35	可是你們都看著我，
0:36	尤其是你，我怎麼量？
0:39	這藉口也太爛了。
0:40	你以前拍的那些性感廣告
0:41	又是怎麼回事？
0:44	可我現在不是在工作，
0:45	我是在找逃出去的路！
0:48	真可惜！
0:70	為什麼要我量
0:71	體重？
0:74	只是好奇。
0:89	你參加奧運時，
0:90	也是穿著衣服量體重嗎？
0:96	不知道，我還以為你
0:97	會把衣服脫掉。體檢不都是
0:98	這樣做的嗎？
0:101	喔，對，當然！
0:104	那就脫掉，告訴我你的體重。
0:107	在這裡？讓大家看著？
0:110	當然，你比賽的時候
0:111	肯定也這樣量吧。
0:119	這真的重要嗎？
0:122	你又不是體育賽事的工作人員，
0:123	當然重要。
0:126	好吧，好吧。
0:141	好，確認一下總是值得的。
0:144	我的體重讓你吃驚嗎？
0:147	沒有。你很高，
0:148	身材也很結實，這體重很合理。
0:197	我滿身是血，
0:198	才不想量體重！
0:208	不用量，
0:209	我記得自己的體重。
0:215	我可是知名明星，
0:216	我不想讓別人知道
0:217	我的體重，尤其是現在！
1:2	拜託，快走吧。你不知道
1:3	這裡還能安全多久！
'''
event = loads((root / 'extracted/Data/Map007.rxdata').read_bytes()).attributes['@events'][21]
pages = event.attributes['@pages']
p = root / 'translation_master.json'
dictionary = json.loads(p.read_text(encoding='utf-8'))
for line in data.strip().splitlines():
    location, translation = line.split('\t', 1)
    page_number, command_number = map(int, location.split(':'))
    command = pages[page_number].attributes['@list'][command_number].attributes
    assert command['@code'] in (101, 401)
    raw = command['@parameters'][0]
    original = raw.decode('cp932') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
    if original in dictionary:
        continue
    dictionary[original] = translation
p.write_text(json.dumps(dictionary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
