from pathlib import Path
from collections import Counter
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString
import json
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')
base = Path(__file__).resolve().parent / 'extracted' / 'Data'
root = Path(__file__).resolve().parent
translated = {}
for name in ('map001_translation.json', 'translation_master.json'):
    translated.update(json.loads((root / name).read_text(encoding='utf-8')))
counts = Counter()

def process(commands):
    for command in commands:
        a = command.attributes
        code = a['@code']
        if code not in (101, 401, 102):
            continue
        values = a['@parameters'][0] if code == 102 else a['@parameters']
        for raw in values:
            if isinstance(raw, (bytes, str, RubyString)):
                text = raw.decode('cp932', 'replace') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
                if not text.strip():
                    continue
                visible = re.sub(r'\\[A-Za-z]\[\d+\]', '', text)
                if text not in translated and any(c.isalpha() for c in visible):
                    counts[text] += 1

for path in base.glob('Map[0-9][0-9][0-9].rxdata'):
    obj = loads(path.read_bytes())
    for event in obj.attributes['@events'].values():
        for page in event.attributes['@pages']:
            process(page.attributes['@list'])
for name in ('CommonEvents', 'Troops'):
    obj = loads((base / f'{name}.rxdata').read_bytes())
    for event in obj:
        if event is None:
            continue
        if name == 'CommonEvents':
            process(event.attributes['@list'])
        else:
            for page in event.attributes['@pages']:
                process(page.attributes['@list'])

print('Unique untranslated with letters:', len(counts), 'occurrences:', sum(counts.values()))
for text, count in counts.most_common(int(sys.argv[1]) if len(sys.argv) > 1 else 100):
    print(count, text, sep='\t')
