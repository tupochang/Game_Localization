import json
from pathlib import Path

p = Path(__file__).with_name('translation_master.json')
d = json.loads(p.read_text(encoding='utf-8'))
d.update({
    'KARINE loses \\v[1560] permanent POWER points.': '卡琳永久失去 \\v[1560] 點力量。',
    'KARINE loses \\v[1560] permanent SPEED points.': '卡琳永久失去 \\v[1560] 點速度。',
    'Congratulations, ': '恭喜！',
    'you can now interact with ': '現在與她互動時，',
    'her at a lower NRG cost.': '消耗的精力更少了。',
    'Try to give her \\v[4] more to lower ': '試著再給她 \\v[4]，',
    'her defenses and interact more ': '讓她放下戒心，',
    'easily with her.': '互動起來會更容易。',
    '   \\v[37] Obedience Point(s)': '   \\v[37] 點服從度',
    '   \\v[37] Love Point(s)': '   \\v[37] 點好感度',
    '   OBEDIENCE PTS: \\v[66]/1000': '   服從度：\\v[66]/1000',
    '   LOVE PTS: \\v[66]/1000': '   好感度：\\v[66]/1000',
    'SANDRA:': '珊卓拉：',
    'CYNTHIA:': '辛西亞：',
    'SAMMY:': '山米：',
    'ALISE:': '艾莉絲：',
    'STEPHEN:': '史蒂芬：',
    'MELANIE:': '梅蘭妮：',
    "I don't know.": '我不知道。',
    '   \\i[54] x2': '   \\i[54] ×2',
    "It's the elevator.": '是電梯。',
    "But it's completely destroyed.": '可是它已經徹底壞了。',
    'Like about everything else.': '跟其他東西一樣。',
    "They're everywhere!": '到處都是！',
    'The gym is burning!': '體育館燒起來了！',
    'Okay, as you prefer.': '好吧，隨你。',
    "Let's get your friend": '先找到你的朋友，',
    'and then leave!': '然後就離開！',
    'Please, don\'t leave us to die...': '拜託，別丟下我們等死……',
    'These chainsaw people are horrible!': '那些拿電鋸的人太可怕了！',
    'Exactly.': '沒錯。',
    'Sorry.': '對不起。',
    'What?': '什麼？',
})
p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
