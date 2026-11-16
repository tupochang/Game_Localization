"""Small ASAR reader/writer for this game's packed Electron application."""
import json
import struct
from pathlib import Path


def read(path):
    data = Path(path).read_bytes()
    header_size = struct.unpack_from('<I', data, 4)[0]
    json_size = struct.unpack_from('<I', data, 12)[0]
    tree = json.loads(data[16:16 + json_size])
    base = 8 + header_size
    return data, tree, base


def files(tree):
    def visit(items, prefix=''):
        for name, item in items.items():
            path = prefix + name
            if 'files' in item:
                yield from visit(item['files'], path + '/')
            else:
                yield path, item
    yield from visit(tree['files'])


def get(data, tree, base, path):
    item = tree['files']
    for part in path.split('/'):
        item = item[part]
        if 'files' in item:
            item = item['files']
    if item.get('unpacked'):
        raise ValueError('Unpacked file: ' + path)
    pos = base + int(item['offset'])
    return data[pos:pos + item['size']]


def pack(original, destination, changes):
    data, tree, base = read(original)
    payload = bytearray()
    originals = {}
    for path, item in files(tree):
        if item.get('unpacked'):
            continue
        old = get(data, tree, base, path)
        originals[path] = old
        new = changes.get(path, old)
        if path in changes and old == new:
            raise ValueError('No change: ' + path)
        item['offset'] = str(len(payload))
        item['size'] = len(new)
        payload.extend(new)
    for path in changes.keys() - originals.keys():
        parts = path.split('/')
        if not parts or any(not part or part in ('.', '..') for part in parts):
            raise ValueError('Invalid added ASAR path: ' + path)
        directory = tree['files']
        for part in parts[:-1]:
            entry = directory.setdefault(part, {'files': {}})
            if 'files' not in entry:
                raise ValueError('ASAR path collides with file: ' + path)
            directory = entry['files']
        if parts[-1] in directory:
            raise ValueError('ASAR path already exists: ' + path)
        new = changes[path]
        directory[parts[-1]] = {'offset': str(len(payload)), 'size': len(new)}
        payload.extend(new)
    header = json.dumps(tree, separators=(',', ':'), ensure_ascii=False).encode('utf-8')
    string_pickle = struct.pack('<I', len(header)) + header
    string_pickle += b'\0' * (-len(string_pickle) % 4)
    pickle = struct.pack('<I', len(string_pickle)) + string_pickle
    output = struct.pack('<I', 4) + struct.pack('<I', len(pickle)) + pickle + payload
    Path(destination).write_bytes(output)
    check, check_tree, check_base = read(destination)
    for path, item in files(tree):
        if item.get('unpacked'):
            continue
        expected = changes.get(path, originals.get(path))
        if get(check, check_tree, check_base, path) != expected:
            raise ValueError('Repack verification failed: ' + path)
