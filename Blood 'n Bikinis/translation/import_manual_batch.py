"""Import manually authored dialogue rows: Map027-3.tsv or CommonEvents-286.tsv.

Each row is page:command<TAB>Traditional Chinese. Keep RPG control codes verbatim.
"""
from pathlib import Path
import json
import sys
from rubymarshal.reader import loads
from rubymarshal.classes import RubyString

root = Path(__file__).parent
batch = Path(sys.argv[1])
stem, event_id = batch.stem.rsplit('-', 1)
event_id = int(event_id)
source = root / 'extracted' / 'Data' / f'{stem}.rxdata'
object_ = loads(source.read_bytes())
if stem == 'CommonEvents':
    pages = [object_[event_id]]
elif stem == 'Troops':
    pages = object_[event_id].attributes['@pages']
else:
    pages = object_.attributes['@events'][event_id].attributes['@pages']
master = root / 'translation_master.json'
translations = json.loads(master.read_text(encoding='utf-8'))
changes = 0
for row in batch.read_text(encoding='utf-8-sig').splitlines():
    if not row or row.startswith('#'):
        continue
    location, translated = row.split('\t', 1)
    page_id, command_id = map(int, location.split(':'))
    command = pages[page_id].attributes['@list'][command_id].attributes
    assert command['@code'] in (101, 401), (location, command['@code'])
    raw = command['@parameters'][0]
    source_text = raw.decode('cp932') if isinstance(raw, bytes) else raw.text if isinstance(raw, RubyString) else raw
    assert isinstance(source_text, str) and translated.strip()
    if source_text in translations:
        if translations[source_text] != translated:
            print(f'EXISTING {location}: {source_text!r} -> {translations[source_text]!r}')
        continue
    translations[source_text] = translated
    changes += 1
master.write_text(json.dumps(translations, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'{batch.name}: {changes} new translations')
