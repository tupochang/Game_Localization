import json
from pathlib import Path

p = Path(__file__).with_name('map001_translation.json')
d = json.loads(p.read_text(encoding='utf-8'))
d.update({
    'Can we not jump?!': '我們不能跳過去嗎？！',
    'Jump?... Laura, I\'m starting to get': '跳過去？……蘿拉，我開始明白',
    'why they care more for your body ': '為什麼大家比較在意你的身材，',
    'than your brains!': '而不是你的腦袋了！',
    'Jump?... now I\'m starting to get ': '跳過去？……我現在開始明白',
    'Hmm, stop making fun of me!': '哼，別再取笑我了！',
    'All gone!': '全都不見了！',
    'What are we going to do now??': '我們現在該怎麼辦？？',
    'Yes, what\'s going on?': '對啊，到底發生什麼事？',
    "I'm afraid, I want to go!": '我好怕，我想離開這裡！',
    'We need to call the police!': '我們得報警！',
    "There's been a terrorist act against us": '有人對我們這些來游泳的人',
    'people who go to the pool!': '發動恐怖攻擊！',
    "It's not gonna be easy.": '恐怕沒那麼簡單。',
    "I think we're going to have to hold": '我想我們還得繼續',
    'onto each other for a little longer!': '互相照應一陣子！',
    "Sorry, I don't think I know you, ": '抱歉，我好像不認識你，',
    'even if you swim in dollars!': '就算你富得流油也一樣！',
    "It's not important!": '那不重要！',
    'Right, I need my motorbike.': '對了，我得去牽我的機車。',
    'Do you have a Harley?': '你騎哈雷嗎？',
    'Where is it?': '車在哪裡？',
    "Just over there, by the pool's exit.": '就在那邊，泳池出口旁。',
    "I must be fast if I don't want the creeps": '我得趕快過去，免得那些怪物',
    'to turn it into trash!': '把它砸成廢鐵！',
    'Then what are we waiting for?': '那我們還等什麼？',
    'My keys are still inside.': '我的鑰匙還在裡面。',
    'I left them in the changing room.': '我把鑰匙留在更衣室了。',
    'My clothes are also there.': '我的衣服也在那裡。',
    "Oh no, it's so bad!": '糟了，這下慘了！',
    'We are all going to die!': '我們全都會死在這裡！',
})
p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
