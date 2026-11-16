"""Inspect untranslated Ink strings in the original ASAR for direct story output.

This is an audit aid, not a proof that every string inside an Ink expression is
hidden: choices, titles and speaker names can also be assembled in expressions.
"""

import csv
import json
from pathlib import Path

from asar_io import get, read
from dump_text import parse_story


HERE = Path(__file__).resolve().parent
GAME = HERE.parent
DUMP = HERE / 'dump' / 'story_dump.json'
OUT = HERE / 'dump' / 'untranslated_direct.tsv'


def at_pointer(root, pointer):
    parts = pointer.removeprefix('#/').split('/')
    node = root
    for part in parts:
        node = node[int(part)] if isinstance(node, list) else node[part]
    return node


def main():
    blob, table, zdata = read(GAME / 'resources' / 'app.original.asar')
    story = parse_story(get(blob, table, zdata, 'src/Questena.js'),
                        'src/Questena.js')
    entries = json.loads(DUMP.read_text(encoding='utf-8'))['entries']
    rows = []
    for entry in entries:
        if entry['status'] != 'untranslated' or not entry['active_count']:
            continue
        for occurrence in entry['occurrences']:
            if occurrence['file'] != 'src/Questena.js':
                continue
            pointer = occurrence['pointer']
            parts = pointer.removeprefix('#/').split('/')
            parent = at_pointer(story, '#/' + '/'.join(parts[:-1]))
            index = int(parts[-1]) if isinstance(parent, list) else parts[-1]
            if not isinstance(parent, list):
                continue
            node = parent[index]
            if not isinstance(node, str) or not node.startswith('^'):
                continue
            depth = 0
            for token in parent[:index]:
                if token == 'ev':
                    depth += 1
                elif token == '/ev':
                    depth -= 1
            rows.append((entry['id'], entry['kind'], entry['original'],
                         'direct' if depth == 0 else 'expression', pointer))

    with OUT.open('w', encoding='utf-8', newline='') as stream:
        writer = csv.writer(stream, delimiter='\t')
        writer.writerow(('id', 'kind', 'original', 'context', 'pointer'))
        writer.writerows(rows)
    direct = [row for row in rows if row[3] == 'direct']
    unique_direct = {}
    for row in direct:
        if row[2].strip():
            unique_direct.setdefault(row[0], row)
    print(f'{len(rows)} untranslated active Ink occurrences; '
          f'{len(direct)} direct output, {len(unique_direct)} distinct nonblank strings.')
    for row in unique_direct.values():
        print(row[0], repr(row[2]), row[4])
    print('Wrote', OUT)


if __name__ == '__main__':
    main()
