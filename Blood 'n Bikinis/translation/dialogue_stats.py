from pathlib import Path
from collections import Counter
from rubymarshal.reader import loads

base = Path(__file__).resolve().parent / 'extracted' / 'Data'
totals = Counter()
unique = set()

def process_list(commands, bucket):
    for command in commands:
        a = command.attributes
        code = a['@code']
        if code not in (101, 401, 102):
            continue
        params = a['@parameters']
        strings = params[0] if code == 102 else params
        for raw in strings:
            if not isinstance(raw, bytes) or not raw.strip():
                continue
            text = raw.decode('cp932', 'replace')
            totals[(bucket, code)] += 1
            unique.add(text)

for path in sorted(base.glob('Map*.rxdata')):
    if path.name == 'MapInfos.rxdata':
        continue
    obj = loads(path.read_bytes())
    for event in obj.attributes['@events'].values():
        for page in event.attributes['@pages']:
            process_list(page.attributes['@list'], path.stem)

obj = loads((base / 'CommonEvents.rxdata').read_bytes())
for event in obj:
    if event:
        process_list(event.attributes['@list'], 'CommonEvents')

obj = loads((base / 'Troops.rxdata').read_bytes())
for troop in obj:
    if troop:
        for page in troop.attributes['@pages']:
            process_list(page.attributes['@list'], 'Troops')

print('Total visible event strings:', sum(totals.values()))
print('Unique visible event strings:', len(unique))
for bucket in sorted({name for name, code in totals}):
    counts = [totals[(bucket, code)] for code in (101, 401, 102)]
    print(bucket, *counts, sum(counts), sep='\t')
