"""List active Ink scenes and export adjacent text with existing translations.

Examples:
  py -3 translation_zhTW/scene_worklist.py --list
  py -3 translation_zhTW/scene_worklist.py --scene FightEttin --output translation_zhTW/scene_fight_ettin.md
"""

import argparse
from collections import defaultdict
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
DUMP = HERE / 'dump' / 'story_dump.json'


def scene_from_pointer(pointer):
    parts = pointer.split('/')
    if len(parts) > 4 and parts[1:3] == ['root', '2']:
        return parts[3]
    return '(startup)'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--list', action='store_true', help='List scenes by untranslated count')
    parser.add_argument('--scene', help='Exact scene name from --list')
    parser.add_argument('--output', type=Path, help='Write scene packet to this Markdown file')
    parser.add_argument('--dump', type=Path, default=DUMP)
    args = parser.parse_args()
    if not args.list and not args.scene:
        parser.error('Choose --list or --scene NAME')

    entries = json.loads(args.dump.read_text(encoding='utf-8'))['entries']
    scenes = defaultdict(list)
    for row in entries:
        if not row['active_count']:
            continue
        pointers = [item['pointer'] for item in row['occurrences']
                    if item['file'] == 'src/Questena.js']
        for scene in sorted({scene_from_pointer(p) for p in pointers}):
            scenes[scene].append(row)

    if args.list:
        counts = [(name, sum(row['status'] == 'untranslated' and row['kind'] == 'text'
                             for row in rows), len(rows)) for name, rows in scenes.items()]
        for name, pending, total in sorted(counts, key=lambda item: (-item[1], item[0])):
            print(f'{pending:4} / {total:4}  {name}')

    if args.scene:
        if args.scene not in scenes:
            parser.error(f'Unknown scene: {args.scene}; use --list')
        rows = scenes[args.scene]
        lines = [f'# {args.scene}', '',
                 f'{len(rows)} unique strings in active story. '
                 'Translations are context only; edit a batch JSON and import it with import_batch.py.', '']
        for row in rows:
            if row['kind'] == 'technical':
                continue
            status = '✓' if row['status'] == 'translated' else '□'
            source = row['original'].replace('\\', '\\\\').replace('`', '\\`').replace('\n', '\\n')
            lines.append(f'### {status} {row["id"]}')
            lines.append(f'Original: `{source}`')
            if row['translation'] is not None:
                translated = row['translation'].replace('\\', '\\\\').replace('`', '\\`').replace('\n', '\\n')
                lines.append(f'Translation: `{translated}`')
            lines.append('')
        result = '\n'.join(lines) + '\n'
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(result, encoding='utf-8')
            print(f'Wrote {args.output} ({len(rows)} unique strings)')
        else:
            print(result)


if __name__ == '__main__':
    main()
