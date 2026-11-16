from pathlib import Path
from collections import Counter
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString
import json, re
root=Path(__file__).resolve().parent
translated={}
for n in ('map001_translation.json','translation_master.json'):
    translated.update(json.loads((root/n).read_text(encoding='utf-8')))
base=root/'extracted'/'Data'
counts=Counter()
for path in [*base.glob('Map[0-9][0-9][0-9].rxdata'),base/'CommonEvents.rxdata']:
    obj=loads(path.read_bytes())
    if path.stem=='CommonEvents': events=((i,e) for i,e in enumerate(obj) if e)
    else: events=obj.attributes['@events'].items()
    for eid,event in events:
        pages=[event] if path.stem=='CommonEvents' else event.attributes['@pages']
        for page in pages:
            for cmd in page.attributes['@list']:
                a=cmd.attributes
                if a['@code'] not in (101,401,102): continue
                vals=a['@parameters'][0] if a['@code']==102 else a['@parameters']
                for raw in vals:
                    if not isinstance(raw,(bytes,str,RubyString)): continue
                    s=raw.decode('cp932','replace') if isinstance(raw,bytes) else raw.text if isinstance(raw,RubyString) else raw
                    visible=re.sub(r'\\[A-Za-z]\[\d+\]','',s)
                    if s not in translated and re.search('[A-Za-z]',visible): counts[(path.stem,eid)]+=1
for k,n in counts.most_common(): print(f'{k[0]}:{k[1]}\t{n}')
