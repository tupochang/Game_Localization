import json
from pathlib import Path
p=Path(__file__).with_name('translation_master.json')
d=json.loads(p.read_text(encoding='utf-8'))
for en,zh in {'Sandy':'珊蒂','Cindy':'辛蒂','Nancy':'南希','Isabelle':'伊莎貝兒','Karine':'卡琳','Alison':'艾莉森','Orange':'奧蘭潔'}.items():
    d[f'   \\n[1] can now interact with {en}.']=f'   \\n[1] 現在可以和{zh}互動了。'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
