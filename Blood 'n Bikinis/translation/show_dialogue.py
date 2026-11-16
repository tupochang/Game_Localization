from pathlib import Path
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString
import sys
sys.stdout.reconfigure(encoding='utf-8')
import json
translated = {}
for filename in ('map001_translation.json', 'translation_master.json'):
    translated.update(json.loads((Path(__file__).parent / filename).read_text(encoding='utf-8')))
only_new = '--new' in sys.argv
event_filter = None
for arg in sys.argv[1:]:
    if arg.startswith('--event='):
        event_filter = int(arg.split('=', 1)[1])

base = Path(__file__).resolve().parent / 'extracted' / 'Data'
for name in [x for x in sys.argv[1:] if not x.startswith('--')]:
    path = base / (name if name.endswith('.rxdata') else name + '.rxdata')
    obj = loads(path.read_bytes())
    print('\n###', path.stem)
    if path.stem.startswith('Map'):
        events = obj.attributes['@events'].items()
    elif path.stem in ('CommonEvents', 'Troops'):
        events = ((i, e) for i, e in enumerate(obj) if e)
    else:
        raise ValueError(path)
    for eid, event in events:
        if event_filter is not None and eid != event_filter:
            continue
        pages = event.attributes['@pages'] if path.stem.startswith('Map') or path.stem == 'Troops' else [event]
        for pi, page in enumerate(pages):
            for ci, command in enumerate(page.attributes['@list']):
                a = command.attributes
                code = a['@code']
                if code not in (101, 401, 102):
                    continue
                values = a['@parameters'][0] if code == 102 else a['@parameters']
                for si, raw in enumerate(values):
                    if not isinstance(raw, (bytes, str, RubyString)):
                        continue
                    text = raw.decode('cp932', 'replace') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
                    if not text.strip():
                        continue
                    if only_new and text in translated:
                        continue
                    print(f'{eid}:{pi}:{ci}:{code}:{si}\t{text}')
