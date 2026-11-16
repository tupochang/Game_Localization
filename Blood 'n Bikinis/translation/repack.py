from pathlib import Path
import hashlib
import struct

root = Path(__file__).resolve().parent.parent
src = root / '_zhTW_work' / 'Game.original.rgssad'
overlay = root / '_zhTW_work' / 'overlay'
dst = root / '_zhTW_work' / 'Game_zhTW.rgssad'
replacements = {
    path.relative_to(overlay).as_posix()
    for path in overlay.rglob('*') if path.is_file()
}

def step(key):
    return (key * 7 + 3) & 0xffffffff

def xor(data, key):
    result = bytearray(data)
    for i in range(0, len(result), 4):
        for j in range(min(4, len(result) - i)):
            result[i + j] ^= (key >> (8 * j)) & 0xff
        key = step(key)
    return result

def entries(path):
    with path.open('rb') as f:
        if f.read(8) != b'RGSSAD\x00\x01':
            raise ValueError('Not an RPG Maker XP archive')
        key = 0xDEADCAFE
        while length_raw := f.read(4):
            length = struct.unpack('<I', length_raw)[0] ^ key
            key = step(key)
            if not 0 < length < 1024:
                raise ValueError(f'Invalid name length: {length}')
            name_raw = f.read(length)
            decoded = bytearray()
            for b in name_raw:
                decoded.append(b ^ (key & 0xff))
                key = step(key)
            name = decoded.decode('cp932').replace('\\', '/')
            size_raw = f.read(4)
            size = struct.unpack('<I', size_raw)[0] ^ key
            key = step(key)
            payload_key = key
            payload = f.read(size)
            if len(payload) != size:
                raise ValueError(f'Truncated {name}')
            yield name, length_raw, name_raw, size_raw, payload_key, payload

count = 0
changed = set()
with dst.open('wb') as out:
    out.write(b'RGSSAD\x00\x01')
    for name, length_raw, name_raw, size_raw, key, payload in entries(src):
        if name in replacements:
            plain = (overlay / name).read_bytes()
            size_raw = struct.pack('<I', len(plain) ^ ((key - 3) * pow(7, -1, 1 << 32) & 0xffffffff))
            # payload key is the state after the size field; reverse one step for that field.
            payload = xor(plain, key)
            changed.add(name)
        out.write(length_raw)
        out.write(name_raw)
        out.write(size_raw)
        out.write(payload)
        count += 1

if changed != replacements:
    raise ValueError(f'Missing replacement entries: {replacements - changed}')

verified = set()
for name, _, _, _, key, payload in entries(dst):
    if name in replacements:
        got = hashlib.sha256(xor(payload, key)).digest()
        expected = hashlib.sha256((overlay / name).read_bytes()).digest()
        if got != expected:
            raise ValueError(f'Verification failed for {name}')
        verified.add(name)
if verified != replacements:
    raise ValueError('Repacked archive index verification failed')
print(f'Repacked {count} entries; verified {len(verified)} translations: {dst}')
