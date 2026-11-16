"""Hand edited Sandra rescue and Murphy decision dialogue."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
data = '''
0:3	珊卓拉！
0:6	跟我們走，我們得離開這裡！
0:9	看她的眼睛！
0:10	別相信她。
0:21	別擔心。
0:22	我沒事。拜託，給我一杯水。
0:23	我好渴。
0:26	我還以為聽到機器人在說話。
0:30	辛蒂現在說話也一個樣，
0:31	怎麼沒見你想把她趕走！
0:34	話說回來，辛蒂可是全裸的！
0:35	可惜我沒帶相機，
0:36	那些照片能賣上幾百萬！
0:39	我的打扮有什麼問題嗎？
0:42	殭屍把她的腦袋
0:43	吃掉了不成？
0:46	差不多。她遇襲了，我們
0:47	好不容易才把她救出來……
0:50	從那時起她就有點恍惚。
0:53	那珊卓拉會不會也
0:54	遭遇了同樣的事？
0:64	總之先找水給她喝吧！
0:67	你想去找嗎？
1:2	蘿拉，拜託幫幫我。
1:3	拿點乾淨的水給我。
1:6	好，我試試看。
1:7	待在這裡，別亂動。
2:2	來，喝點水。
2:5	謝謝你，
2:6	真的太謝謝你了！
2:9	你還好嗎？
2:12	我想……應該沒事。
2:14	我想跟你們一起走。
2:15	大家都死了！
2:20	墨菲死了？！
2:23	不是，我是說他被感染了……
2:24	我設法把他鎖進
2:25	辦公室旁的小房間……
2:28	真的？！
2:31	對！
2:40	墨菲是這所學校的校長，對吧？
2:43	對，可我想我們該去看看他。
2:44	說不定他只是害怕，
2:45	才躲進那間小房間？
2:48	不，我確定
2:49	他不對勁！
2:50	別去那裡！
2:53	你上次見到他是多久前？
2:56	不知道，幾個小時前吧。
2:59	你覺得我們該怎麼辦？
2:62	當然是離開！
2:63	趁還來得及，
2:64	大家一起走吧！
2:67	那你們想怎麼做？
2:68	這可是你們的學校！
2:71	我不知道，我開始害怕了。
2:75	我覺得墨菲是個好校長。
2:78	辛蒂，像你這樣的大明星，
2:79	怎麼可以不穿衣服！
2:82	我不知道發生了什麼……
2:83	我……當時沒察覺，後來就太遲了……
2:86	你這樣太不像話了。
2:87	現在看起來像個蕩婦！
2:89	蘿拉嘛，我能理解，
2:90	她本來就是蕩婦，可是……
2:93	哼，我才不是蕩婦！
2:96	珊卓拉，我的朋友，恐怕要讓你失望了……
2:99	辛蒂，抱歉我說得太直接，
2:100	但你看起來太可口了，我真想
2:101	把你那對大胸部塞進嘴裡！
2:104	你想吃掉我？？！
2:109	蘿拉，抱歉我說得太直接，
2:110	但你看起來太可口了，我真想
2:111	咬你的胸部一口！
2:114	不要，拜託別這樣！
2:129	他們全都變成這樣了，
2:130	根本沒人能救！
2:133	鑰匙在她身上，至少去看看
2:134	墨菲吧。畢竟他
2:135	為我們做了那麼多！
2:138	我同意。他的辦公室就在樓上，
2:139	花不了多久。
2:142	可是他也變成怪物了呢？
2:146	那說不定還來得及
2:147	像救辛蒂一樣救他！
2:150	我被救了？
2:155	那……我也不知道了。
2:158	我們就跟他打，打倒他。
2:159	走吧！
'''
event = loads((root / 'extracted/Data/Map036.rxdata').read_bytes()).attributes['@events'][27]
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
