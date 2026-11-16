from pathlib import Path
from rubymarshal.reader import loads
from collections import Counter
import re,sys
sys.stdout.reconfigure(encoding='utf-8')
p=Path(__file__).resolve().parent/'extracted'/'Data'
c=Counter()
for q in [*p.glob('Map???.rxdata'),p/'CommonEvents.rxdata',p/'Troops.rxdata']:
    o=loads(q.read_bytes())
    evs=o.attributes['@events'].values() if q.stem.startswith('Map') else (e for e in o if e)
    for e in evs:
        pages=e.attributes['@pages'] if q.stem.startswith('Map') or q.stem=='Troops' else [e]
        for page in pages:
            for cmd in page.attributes['@list']:
                a=cmd.attributes
                if a['@code'] not in (355,655):continue
                raw=a['@parameters'][0]
                if not isinstance(raw,bytes):continue
                s=raw.decode('cp932','replace')
                m=re.match(r'\s*(line[123])\s*=\s*"((?:[^"\\]|\\.)*)"\s*$',s)
                if m and m.group(2):c[m.group(2)]+=1
for text,count in c.most_common():print(f'{count}\t{text}')
print('UNIQUE',len(c),'TOTAL',sum(c.values()))
