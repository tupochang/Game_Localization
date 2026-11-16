import json
from pathlib import Path
from extra_info_translations import translate
p=Path(__file__).with_name('extra_info_inventory.txt')
mapping={}
for line in p.read_text(encoding='utf-8').splitlines():
    if line.startswith('UNIQUE'):continue
    _,source=line.split('\t',1)
    target=translate(source)
    if target is None:raise ValueError(source)
    if '#{' in source and source.count('#{')!=target.count('#{'):
        raise ValueError(f'Lost Ruby interpolation: {source} => {target}')
    if '"' in target:raise ValueError(f'Unescaped double quote: {target}')
    mapping[source]=target
out=Path(__file__).with_name('extra_info_translations.json')
out.write_text(json.dumps(mapping,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(len(mapping),out)
