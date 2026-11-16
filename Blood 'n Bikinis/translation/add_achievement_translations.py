import json
from pathlib import Path

path = Path(__file__).with_name('translation_master.json')
data = json.loads(path.read_text(encoding='utf-8'))

names = {'Laura': '蘿拉', 'Sandy': '珊蒂', 'Cindy': '辛蒂', 'Nancy': '南希', 'Isa': '伊莎', 'Karine': '卡琳', 'Alison': '艾莉森', 'Orange': '奧蘭潔'}
for english, chinese in names.items():
    data[f'{english} has killed more than 15 monsters'] = f'{chinese}使用武器擊敗超過 15 隻怪物。'
    data[f'{english} has killed more than 10 monsters.'] = f'{chinese}擊敗超過 10 隻怪物。'
    data[f'{english} has killed more than 30 monsters.'] = f'{chinese}擊敗超過 30 隻怪物。'
    data[f'{english} has killed more than '] = f'{chinese}使用技能擊敗超過'
    data[f'{english} has been in more than 50 fights.'] = f'{chinese}參與超過 50 場戰鬥。'
data['with her weapon.'] = ''
data['10 monsters using skills.'] = '10 隻怪物。'

path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
