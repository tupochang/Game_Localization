from pathlib import Path
import struct

src = Path(__file__).resolve().parent.parent / 'Game.rgssad'
out = Path(__file__).resolve().parent / 'extracted'

def advance(key):
    return (key * 7 + 3) & 0xffffffff

with src.open('rb') as f:
    assert f.read(8) == b'RGSSAD\x00\x01'
    key = 0xDEADCAFE
    count = 0
    while length_data := f.read(4):
        length = struct.unpack('<I', length_data)[0] ^ key
        key = advance(key)
        if length > 1000:
            raise ValueError(f'Bad name length {length} at {f.tell()}')
        raw_name = bytearray()
        for byte in f.read(length):
            raw_name.append(byte ^ (key & 0xff))
            key = advance(key)
        name = raw_name.decode('cp932')
        size = struct.unpack('<I', f.read(4))[0] ^ key
        key = advance(key)
        target = out / name.replace('\\', '/')
        if not target.resolve().is_relative_to(out.resolve()):
            raise ValueError(name)
        target.parent.mkdir(parents=True, exist_ok=True)
        data = bytearray(f.read(size))
        file_key = key
        for i in range(0, len(data), 4):
            for j in range(min(4, len(data) - i)):
                data[i + j] ^= (file_key >> (j * 8)) & 0xff
            file_key = advance(file_key)
        target.write_bytes(data)
        count += 1
    print(f'Extracted {count} files to {out}')
