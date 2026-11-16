import json
from pathlib import Path
from database_translations import DATA

p=Path(__file__).with_name('database_translations.json')
p.write_text(json.dumps(DATA,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(p)
