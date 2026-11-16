from pathlib import Path
import hashlib
import struct

root = Path(__file__).resolve().parent.parent
input_dir = root / '立繪替換' / '替換圖'
original_dir = root / '立繪替換' / '原圖'
src = root / 'Game.rgssad'
dst = root / '_zhTW_work' / 'Game_with_portraits.rgssad'

def step(key):
    return (key * 7 + 3) & 0xffffffff

def xor(data, key):
    result = bytearray(data)
    for i in range(0, len(result), 4):
        for j in range(min(4, len(result) - i)):
            result[i + j] ^= (key >> (8 * j)) & 0xff
        key = step(key)
    return result

def png_size(path):
    header = path.read_bytes()[:24]
    if header[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'Not a PNG: {path}')
    return struct.unpack('>II', header[16:24])

def entries(path):
    with path.open('rb') as f:
        if f.read(8) != b'RGSSAD\x00\x01':
            raise ValueError('Not an RPG Maker XP archive')
        key = 0xDEADCAFE
        while length_raw := f.read(4):
            length = struct.unpack('<I', length_raw)[0] ^ key
            key = step(key)
            name_raw = f.read(length)
            decoded = bytearray()
            for byte in name_raw:
                decoded.append(byte ^ (key & 0xff))
                key = step(key)
            name = decoded.decode('cp932').replace('\\', '/')
            size_raw = f.read(4)
            size = struct.unpack('<I', size_raw)[0] ^ key
            key = step(key)
            payload_key = key
            payload = f.read(size)
            if len(payload) != size:
                raise ValueError(f'Truncated archive entry: {name}')
            yield name, length_raw, name_raw, size_raw, payload_key, payload

replacements = {}
for path in input_dir.glob('*.png'):
    original = original_dir / path.name
    if not original.is_file():
        raise ValueError(f'Unknown game picture: {path.name}')
    if png_size(path) != png_size(original):
        raise ValueError(f'Canvas size differs from original: {path.name}')
    replacements[f'Graphics/Pictures/{path.name}'.lower()] = path
if not replacements:
    raise SystemExit(f'No replacement PNG files in {input_dir}')

found = set()
with dst.open('wb') as out:
    out.write(b'RGSSAD\x00\x01')
    for name, length_raw, name_raw, size_raw, key, payload in entries(src):
        lookup = name.lower()
        if lookup in replacements:
            plain = replacements[lookup].read_bytes()
            metadata_key = ((key - 3) * pow(7, -1, 1 << 32)) & 0xffffffff
            size_raw = struct.pack('<I', len(plain) ^ metadata_key)
            payload = xor(plain, key)
            found.add(lookup)
        out.write(length_raw)
        out.write(name_raw)
        out.write(size_raw)
        out.write(payload)
if found != set(replacements):
    raise ValueError(f'Pictures absent from archive: {set(replacements) - found}')

verified = set()
for name, _, _, _, key, payload in entries(dst):
    lookup = name.lower()
    if lookup in replacements:
        actual = hashlib.sha256(xor(payload, key)).digest()
        expected = hashlib.sha256(replacements[lookup].read_bytes()).digest()
        if actual != expected:
            raise ValueError(f'Failed verification: {name}')
        verified.add(lookup)
if verified != set(replacements):
    raise ValueError('Repacked archive verification failed')
print(f'Prepared {len(verified)} replacements in {dst}; current game archive was not changed')
