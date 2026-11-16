from pathlib import Path
from rubymarshal.reader import loads
from collections import Counter
import re,sys
sys.stdout.reconfigure(encoding='utf-8')
base=Path(__file__).resolve().parent/'extracted'/'Data'
counts=Counter()
for path in [*base.glob('Map???.rxdata'),base/'CommonEvents.rxdata',base/'Troops.rxdata']:
    o=loads(path.read_bytes())
    evs=o.attributes['@events'].items() if path.stem.startswith('Map') else enumerate(o)
    for eid,e in evs:
        if e is None:continue
        pages=e.attributes['@pages'] if path.stem.startswith('Map') or path.stem=='Troops' else [e]
        for pi,page in enumerate(pages):
            for ci,c in enumerate(page.attributes['@list']):
                a=c.attributes
                if a['@code'] not in (355,655):continue
                raw=a['@parameters'][0]
                if not isinstance(raw,bytes):continue
                s=raw.decode('cp932','replace')
                if re.search(r'(?i)quest|owner|location|goal|info',s) or re.search(r'"[A-Za-z][A-Za-z ]{3,}"',s):
                    print(f'{path.stem}:{eid}:{pi}:{ci}\t{s}')
