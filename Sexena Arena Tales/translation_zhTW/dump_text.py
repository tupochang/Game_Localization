"""Export the original Ink story and HTML UI text with translation coverage.

Run from any directory: py -3 dump_text.py [--out-dir DIRECTORY] [--active-only]
The JSON keeps exact source strings; TSV files make the dump easy to review.
"""

import argparse
import csv
from html.parser import HTMLParser
import json
from pathlib import Path
import re

from asar_io import files, get, read


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
ORIGINAL = ROOT / 'resources' / 'app.original.asar'
ACTIVE_STORY = 'src/Questena.js'


def translations():
    mapping = {}
    sources = [HERE / 'strings.json', *sorted(HERE.glob('strings_*.json'))]
    for source in sources:
        additions = json.loads(source.read_text(encoding='utf-8'))
        overlap = mapping.keys() & additions.keys()
        if overlap:
            raise ValueError(f'Duplicate source keys in {source.name}: {sorted(overlap)!r}')
        mapping.update(additions)
    return mapping


def pointer(parts):
    return '#/' + '/'.join(str(part).replace('~', '~0').replace('/', '~1') for part in parts)


def walk_story(value, path=()):
    if isinstance(value, str) and value.startswith('^'):
        yield value[1:], pointer(path)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from walk_story(child, (*path, index))
    elif isinstance(value, dict):
        for key, child in value.items():
            yield from walk_story(child, (*path, key))


def parse_story(raw, path):
    source = raw.decode('utf-8-sig')
    start = source.find('{')
    if start < 0:
        raise ValueError(f'No compiled Ink JSON found in {path}')
    story, _ = json.JSONDecoder(strict=False).raw_decode(source[start:])
    if not isinstance(story, dict) or 'root' not in story:
        raise ValueError(f'Unexpected Ink data in {path}')
    return story


def kind(original):
    """Review hint only; the complete dump always retains every Ink string."""
    value = original.strip()
    if not value or value in {'{', '}'}:
        return 'technical'
    if re.fullmatch(r'[A-Za-z0-9_./-]+', value):
        return 'technical'
    if re.fullmatch(r'[^\w]+', value):
        return 'technical'
    if re.fullmatch(r'0x[0-9a-fA-F]+', value):
        return 'technical'
    if re.search(r'\.(png|jpg|jpeg|webp|gif|json|mp3|ogg|wav)$', value, re.I):
        return 'technical'
    if value.startswith(('x:', 'y:', 'opacity:', 'uiicon ', 'render_height',
                         'stretch', 'delay-', 'chapterui ', 'title chapterui ', 'load:',
                         'saveto:', 'set_var:', 'pause:', 'icall:', 'howler:',
                         'clear:', 'lock_achievement:', 'unlock_achievement:',
                         'style>', 'img class=', '.json:', "' src='")):
        return 'technical'
    if any(token in value for token in ('<div', '</div', 'class=', 'jquery:', 'attr:',
                                         'timescale:', 'scale:', 'tint:', ',action:',
                                         ",y:", ",'x:", "stop()")):
        return 'technical'
    if value.startswith((',:', ',y:', ',loop:', ",attr:", ":'x:", ':"action:')):
        return 'technical'
    return 'text'


class VisibleHTML(HTMLParser):
    ATTRIBUTES = {'alt', 'aria-label', 'placeholder', 'title', 'value'}
    VOID_TAGS = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
                 'link', 'meta', 'param', 'source', 'track', 'wbr'}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.entries = []

    def handle_starttag(self, tag, attrs):
        if tag not in self.VOID_TAGS:
            self.stack.append(tag)
        if any(parent in {'script', 'style', 'template'} for parent in self.stack):
            return
        for name, value in attrs:
            if name in self.ATTRIBUTES and value and value.strip():
                self.entries.append({'line': self.getpos()[0], 'tag': tag,
                                     'place': '@' + name, 'text': value})

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in self.VOID_TAGS:
            self.stack.pop()

    def handle_endtag(self, tag):
        if tag in self.stack:
            del self.stack[len(self.stack) - 1 - self.stack[::-1].index(tag):]

    def handle_data(self, data):
        if any(tag in {'script', 'style', 'template'} for tag in self.stack):
            return
        if data.strip():
            self.entries.append({'line': self.getpos()[0],
                                 'tag': self.stack[-1] if self.stack else '',
                                 'place': 'text', 'text': data})


def cell(value):
    """Keep each TSV record on one line while preserving escapes in JSON."""
    return json.dumps(value, ensure_ascii=False)[1:-1]


def write_tsv(path, columns, rows):
    with path.open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream, delimiter='\t', lineterminator='\n')
        writer.writerow(columns)
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out-dir', type=Path, default=HERE / 'dump',
                        help='Directory for the exported JSON and TSV files')
    parser.add_argument('--active-only', action='store_true',
                        help='Skip the four compiled Ink copies not loaded by index.html')
    args = parser.parse_args()

    mapping = translations()
    data, tree, base = read(ORIGINAL)
    candidates = [path for path, _ in files(tree)
                  if path == ACTIVE_STORY or (path.startswith('src/') and path.endswith('/Questena.js'))]
    if ACTIVE_STORY not in candidates:
        raise ValueError(f'Missing active story: {ACTIVE_STORY}')
    story_paths = [ACTIVE_STORY, *sorted(path for path in candidates if path != ACTIVE_STORY)]
    if args.active_only:
        story_paths = [ACTIVE_STORY]

    entries = {}
    occurrence_count = 0
    for story_path in story_paths:
        story = parse_story(get(data, tree, base, story_path), story_path)
        for original, location in walk_story(story):
            occurrence_count += 1
            if original not in entries:
                entries[original] = {'id': f'S{len(entries) + 1:05d}',
                                     'original': original, 'translation': mapping.get(original),
                                     'kind': kind(original),
                                     'occurrences': []}
            entries[original]['occurrences'].append({'file': story_path, 'pointer': location})

    active_strings = set()
    for entry in entries.values():
        active_count = sum(item['file'] == ACTIVE_STORY for item in entry['occurrences'])
        if active_count:
            active_strings.add(entry['original'])
        entry['active_count'] = active_count
        entry['total_count'] = len(entry['occurrences'])
        entry['status'] = ('translated' if entry['original'] in mapping else 'untranslated') if active_count else 'archive_only'
    missing = mapping.keys() - active_strings
    if missing:
        raise ValueError(f'Translation keys missing from active story: {sorted(missing)!r}')

    html = VisibleHTML()
    html.feed(get(data, tree, base, 'src/index.html').decode('utf-8-sig'))
    out = args.out_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    records = list(entries.values())
    stats = {'unique_strings': len(records), 'occurrences': occurrence_count,
             'active_unique': len(active_strings),
             'active_translated': len(mapping),
             'active_untranslated': len(active_strings) - len(mapping),
             'active_untranslated_text_candidates': sum(
                 entry['status'] == 'untranslated' and entry['kind'] == 'text'
                 for entry in records),
             'html_entries': len(html.entries)}
    (out / 'story_dump.json').write_text(json.dumps({
        'source_asar': str(ORIGINAL), 'active_story': ACTIVE_STORY,
        'story_files': story_paths, 'stats': stats,
        'entries': records, 'html_entries': html.entries,
    }, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    columns = ['id', 'status', 'kind', 'active_count', 'total_count', 'first_location',
               'original_escaped', 'translation_escaped']
    def row(entry):
        location = entry['occurrences'][0]
        return [entry['id'], entry['status'], entry['kind'], entry['active_count'], entry['total_count'],
                location['file'] + location['pointer'], cell(entry['original']),
                cell(entry['translation']) if entry['translation'] is not None else '']
    write_tsv(out / 'story_dump.tsv', columns, (row(entry) for entry in records))
    write_tsv(out / 'untranslated_active.tsv', columns,
              (row(entry) for entry in records if entry['status'] == 'untranslated'))
    write_tsv(out / 'untranslated_text.tsv', columns,
              (row(entry) for entry in records
               if entry['status'] == 'untranslated' and entry['kind'] == 'text'))
    write_tsv(out / 'html_dump.tsv', ['line', 'tag', 'place', 'text_escaped'],
              ([entry['line'], entry['tag'], entry['place'], cell(entry['text'])]
               for entry in html.entries))
    print(json.dumps(stats, ensure_ascii=False))
    print(f'Exported to {out}')


if __name__ == '__main__':
    main()
