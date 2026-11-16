"""Hand edited Mandy and Cynthia encounter."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
5	我認識她，我認識這個女孩！
11	辛西亞到底是誰？
14	學校裡一個很有人氣的女孩，
15	是第二期的學生。
17	她很高，也很漂亮，
18	身材曲線特別好。
21	沒我漂亮。
24	但肯定比你高！
27	所以她就是曼蒂。
28	我們要怎麼救她出來……還是不要？
30	她平常也總是這樣
31	眼神空洞、一聲不吭嗎？
34	……差不多。
35	她們對辛西亞有種迷戀。
40	喔，所以你是說，
41	有人把她關在這裡？
44	如果是辛西亞做的，確實可能。
47	我討厭辛西亞。她笨得很，
48	又愛炫耀自己的大胸部。
52	嗯，這房間藏得很隱密，
53	也隔開了外面的混亂。
58	我沒——
61	等一下，我在自言自語。
64	喔，抱歉。
69	曼蒂？聽得到嗎？
84	誰知道她們會不會
85	突然變成怪物，真叫人摸不著頭緒！
92	嗨，曼蒂，最近過得怎麼樣？
113	該死，她果然是怪物！
114	牠們怎麼找到這裡的？
117	我不知道。我們到底在躲什麼，
118	我也完全搞不清楚！
121	她現在死了，搞不好
122	早就已經沒了人的意識！
125	你這話太不體貼了。
128	對不起，我……
129	我不知道。走吧，好嗎？
141	還是這樣比較安全。她看起來
142	有點恍惚，不太清醒。
145	要是我整天被關在籠子裡，
146	大概也會那樣。
'''
event = loads((root / 'extracted/Data/Map043.rxdata').read_bytes()).attributes['@events'][1]
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
