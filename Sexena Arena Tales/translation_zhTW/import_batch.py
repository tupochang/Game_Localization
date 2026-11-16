"""Convert human-reviewed DUMP-ID translations into exact Ink source mappings."""

import argparse
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('batch', type=Path, help='JSON object mapping DUMP IDs to Traditional Chinese')
    parser.add_argument('output', type=Path, help='Output strings_*.json consumed by build.py')
    parser.add_argument('--dump', type=Path, default=HERE / 'dump' / 'story_dump.json')
    args = parser.parse_args()

    dump = json.loads(args.dump.read_text(encoding='utf-8'))
    by_id = {row['id']: row for row in dump['entries']}
    proposals = json.loads(args.batch.read_text(encoding='utf-8'))
    if not isinstance(proposals, dict) or not proposals:
        raise ValueError('The batch must be a nonempty JSON object')
    existing = {}
    for source in [HERE / 'strings.json', *sorted(HERE.glob('strings_*.json'))]:
        if source.resolve() != args.output.resolve():
            existing.update(json.loads(source.read_text(encoding='utf-8')))

    converted = {}
    for id_, translation in proposals.items():
        row = by_id.get(id_)
        if row is None:
            raise ValueError(f'Unknown DUMP ID: {id_}')
        if not row['active_count']:
            raise ValueError(f'Not in the active story: {id_}')
        if not isinstance(translation, str) or not translation.strip():
            raise ValueError(f'Empty or invalid translation: {id_}')
        source = row['original']
        if source in existing:
            raise ValueError(f'Already translated: {id_}')
        if source in converted:
            raise ValueError(f'Duplicate original in batch: {id_}')
        converted[source] = translation

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(converted, ensure_ascii=False, indent=2) + '\n',
                           encoding='utf-8')
    print(f'Imported {len(converted)} human-reviewed translations into {args.output}')


if __name__ == '__main__':
    main()
