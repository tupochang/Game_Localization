from pathlib import Path
from collections import Counter
import csv
from rubymarshal.reader import loads
from rubymarshal.classes import RubyObject

base = Path(__file__).resolve().parent / 'extracted' / 'Data'
rows = []
codes = Counter()

def walk(value, path):
    if isinstance(value, RubyObject):
        attrs = value.attributes
        if '@code' in attrs and '@parameters' in attrs:
            code = attrs['@code']
            codes[code] += 1
            if code in (101, 401, 102, 402, 403, 404, 355, 655, 108, 408):
                for i, p in enumerate(attrs['@parameters']):
                    walk(p, path + f'/code{code}/p{i}')
            return
        for k, v in attrs.items():
            walk(v, path + '/' + k)
    elif isinstance(value, dict):
        for k, v in value.items():
            walk(v, path + '/' + str(k))
    elif isinstance(value, (list, tuple)):
        for i, v in enumerate(value):
            walk(v, path + f'/{i}')
    elif isinstance(value, bytes):
        try:
            s = value.decode('cp932')
        except UnicodeDecodeError:
            return
        if any(c.isalpha() for c in s) and len(s) > 1:
            rows.append((path, s))

for f in sorted(base.glob('*.rxdata')):
    try:
        walk(loads(f.read_bytes()), f.name)
    except Exception as e:
        print('ERROR', f.name, str(e)[:100])

with (Path(__file__).parent / 'text_inventory.tsv').open('w', encoding='utf-8', newline='') as f:
    w = csv.writer(f, delimiter='\t', quoting=csv.QUOTE_ALL, escapechar='\\')
    w.writerow(['location', 'text'])
    w.writerows(rows)
print('Text rows', len(rows), 'Unique', len(set(t for _, t in rows)))
print('Event codes', codes.most_common(20))
