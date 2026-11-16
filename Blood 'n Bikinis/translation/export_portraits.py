from pathlib import Path
import csv
import shutil
import struct

root = Path(__file__).resolve().parent.parent
source = root / '_zhTW_work' / 'extracted' / 'Graphics' / 'Pictures'
target = root / '立繪替換' / '原圖'
target.mkdir(parents=True, exist_ok=True)
rows = []
for path in sorted(source.iterdir()):
    if path.suffix.lower() != '.png':
        continue
    header = path.read_bytes()[:24]
    if header[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'Invalid PNG: {path.name}')
    width, height = struct.unpack('>II', header[16:24])
    shutil.copy2(path, target / path.name)
    rows.append((path.name, width, height))

manifest = target.parent / '圖片清單.csv'
with manifest.open('w', encoding='utf-8-sig', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(('檔名', '寬', '高'))
    writer.writerows(rows)
print(f'Exported {len(rows)} PNG files to {target}')
