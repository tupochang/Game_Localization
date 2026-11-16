"""Hand edited confrontation with Lawrence."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
0:3	我還以為你死了！
0:6	我就在這裡。我命硬得很。
0:7	比你這個肌肉男
0:8	想像的還要硬。
0:11	這場混亂是怎麼回事，
0:12	你欠我們一個解釋。
0:15	省點口水吧，你的、我的都一樣。
0:16	我們沒辦法活著出去。
0:19	為什麼？？會發生什麼事？？
0:22	肌肉男挑女人果然
0:23	不看腦袋，對吧？
0:25	開始向你的神祈禱吧，
0:26	如果你有信仰的話。
0:28	或者趁還有時間，
0:29	跟這群女孩狂歡一場！
0:32	不！我們都走到這一步了，
0:33	沒理由認定自己撐不下去！
0:36	這話你去跟多米尼恩說吧，
0:37	沒腦子的富家女。
0:40	多米尼……什麼？
0:43	……我承認，你現在這處境
0:44	還敢不躲進角落，
0:45	有點膽量，但完全沒腦子。
0:47	奧蘭琪，臭名昭彰的逃兵，
0:48	你要不要給這個裸著的蕩婦解釋一下？
0:51	勞倫斯，我對多米尼恩
0:52	一無所知，還是叫多米尼昂？
0:55	對你來說，我是勞倫斯大人！
0:57	你看，她也不知道。
0:58	那你就繼續蒙在鼓裡吧。
0:61	我看這傢伙只是個蠢貨，
0:62	我們幹嘛聽他說話？
0:65	算你走運，現在不適合
0:66	做實驗。不然我會把你當成
0:67	我的東西，讓你嘗嘗想像不到的滋味！
0:70	那真可惜啊，白痴！
1:2	那就去吧。
1:3	迎接你們的命運。
'''
event = loads((root / 'extracted/Data/Map034.rxdata').read_bytes()).attributes['@events'][11]
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
