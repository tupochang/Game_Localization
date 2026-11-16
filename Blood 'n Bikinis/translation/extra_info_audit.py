from pathlib import Path
from extra_info_translations import translate
import sys
sys.stdout.reconfigure(encoding='utf-8')
p=Path(__file__).with_name('extra_info_inventory.txt')
rows=[]
for line in p.read_text(encoding='utf-8').splitlines():
    if line.startswith('UNIQUE'):continue
    n,s=line.split('\t',1)
    rows.append((int(n),s))
missing=[(n,s) for n,s in rows if translate(s) is None]
print(f'Translated {len(rows)-len(missing)}/{len(rows)} unique; missing {sum(n for n,s in missing)} occurrences')
for n,s in missing:print(f'{n}\t{s}')
