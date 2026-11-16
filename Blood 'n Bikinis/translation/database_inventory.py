from pathlib import Path
from rubymarshal.reader import loads
from collections import Counter
import sys
sys.stdout.reconfigure(encoding='utf-8')
base=Path(__file__).resolve().parent/'extracted'/'Data'
for name in ['Actors','Classes','Items','Skills','Weapons','Armors','Enemies','States','MapInfos']:
    obj=loads((base/(name+'.rxdata')).read_bytes())
    rows=obj.items() if isinstance(obj,dict) else enumerate(obj)
    print('\n###',name)
    fields=Counter()
    for i,row in rows:
        if row is None: continue
        attrs=row.attributes
        selected=[]
        for field in ('@name','@description'):
            raw=attrs.get(field)
            if not raw: continue
            s=raw.decode('cp932','replace') if isinstance(raw,bytes) else str(raw)
            if not s.strip(): continue
            selected.append(f'{field[1:]}={s}')
            fields[field]+=1
        if selected: print(i,' '.join(selected),sep='\t')
    print('counts',dict(fields))
