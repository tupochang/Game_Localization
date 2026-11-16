"""Hand authored stat reward wording for each party member."""
from pathlib import Path
import json
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
event = loads((root / 'extracted/Data/CommonEvents.rxdata').read_bytes())[38]
commands = event.attributes['@list']
p = root / 'translation_master.json'
dictionary = json.loads(p.read_text(encoding='utf-8'))
names = {'\\n[1]': '\\n[1]', 'LAURA': '蘿拉', 'NANCY': '南希',
         'CINDY': '辛蒂', 'SANDY': '珊蒂', 'ALISON': '艾莉森',
         'ISA': '伊莎', 'ORANGE': '奧蘭琪'}
for command in commands:
    attributes = command.attributes
    if attributes['@code'] != 401:
        continue
    raw = attributes['@parameters'][0]
    original = raw.decode('cp932') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
    if original in dictionary:
        continue
    for english, chinese in names.items():
        for stat, localized in [('POWER', '力量'), ('SPEED', '速度')]:
            if original == f'{english} gains \\v[1559] permanent {stat} points.':
                dictionary[original] = f'{chinese}永久增加 \\v[1559] 點{localized}。'
assert all((raw := c.attributes['@parameters'][0]) and
           (raw.decode('cp932') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw) in dictionary
           for c in commands if c.attributes['@code'] == 401 and
           'permanent' in str(c.attributes['@parameters'][0]))
p.write_text(json.dumps(dictionary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
