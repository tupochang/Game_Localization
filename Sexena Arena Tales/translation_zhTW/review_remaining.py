"""Classify every untranslated active Ink string for manual review.

The ID ranges below follow the original story DUMP. Any new or unclassified
string causes an error so that a future game update cannot silently pass.
"""

import csv
import hashlib
import json
from collections import Counter
from pathlib import Path


HERE = Path(__file__).resolve().parent
SOURCE_SHA256 = '20cd7c3722b26891c25655dee67e1b0c9debf7188f13dd278c766cb0674cad9e'


def category(number):
    if number == 135 or number in (4291,):
        return 'color', '畫面顏色常數；變更會影響色彩。'
    if number == 140:
        return 'brand', '標題畫面的 Sexena 標誌，保留原品牌字形。'
    if number in (139, 142, 446, 526, 2033):
        return 'space', '空字串或排版空白。'
    if number == 150:
        return 'ink_command', '重新開始時的存檔目標指令。'
    if 1 <= number <= 19 or 151 <= number <= 169:
        return 'markup', 'HTML 標籤、CSS 類別或拼接片段；不是對話。'
    if 20 <= number <= 23 or 24 <= number <= 138:
        return 'visual_key', '圖像、動畫、姿勢或結局資源識別值。'
    if 147 <= number <= 149:
        return 'ui_id', '傳給 show_ui_id 等函式的介面元素 ID。'
    if 172 <= number <= 199:
        return 'scene_command', '場景圖層、動畫參數或資源路徑片段。'
    if 200 <= number <= 240:
        return 'audio_key', '音效、語音或音樂檔名。'
    if 241 <= number <= 249:
        return 'audio_command', 'Howler 音訊指令片段。'
    if 255 <= number <= 268:
        return 'call_fragment', '數值常數或 icall 介面指令片段。'
    if 282 <= number <= 299 or number in (150, 325, 326, 335, 1784, 1793):
        return 'ink_command', '儲存、讀取、UI 更新或選項樣式指令。'
    if number in (309, 331, 1155, 4138):
        return 'punctuation', '標點、分隔符或省略號片段。'
    if 345 <= number <= 346 or 403 <= number <= 421 or 527 <= number <= 540 or number in (2000, 4082):
        return 'achievement_key', '成就鎖定或解鎖指令與鍵名。'
    if number in (353, 525):
        return 'ink_path', 'Ink 場景跳轉路徑。'
    if number in (390, 391, 1794, 4090):
        return 'numeric', '除錯座標或數值常數。'
    if number == 520:
        return 'css_class', '選單 CSS 類別。'
    if number == 703:
        return 'entity', '省略號的 HTML 實體。'
    if number == 1194 or 4225 <= number <= 4227:
        return 'control_value', '寫入 Ink 變數的分支控制值，非選項顯示文字。'
    if 4062 <= number <= 4080:
        return 'credit_name', '片尾製作名單的人名或暱稱。'
    if 4084 <= number <= 4088 or 4175 <= number <= 4179 or number == 4214:
        return 'card_key', '紙牌樣式、花色或圖像資源鍵。'
    if 4251 <= number <= 4261:
        return 'render_config', '渲染尺寸、圖層清單或影像設定。'
    if 4262 <= number <= 4282:
        return 'style_key', 'CSS 樣式、文字效果或介面狀態鍵。'
    if 4283 <= number <= 4290:
        return 'icon', '介面圖示符號，無英文字。'
    if 4292 <= number <= 4324:
        return 'visual_key', '背景圖檔或角色視覺資源鍵。'
    if 4325 <= number <= 4332:
        return 'effect_key', '畫面特效資源鍵。'
    if 4333 <= number <= 4336:
        return 'control_value', '布林值或控制指令。'
    if number in (4337, 4342):
        return 'watchvar_config', '狀態欄變數清單或同步指令；顯示名稱已另譯。'
    raise ValueError(f'Unclassified active string S{number:05d}')


def main():
    original = HERE.parent / 'resources' / 'app.original.asar'
    if hashlib.sha256(original.read_bytes()).hexdigest() != SOURCE_SHA256:
        raise ValueError('Original ASAR changed; remaining-string categories need review')
    dump = json.loads((HERE / 'dump' / 'story_dump.json').read_text(encoding='utf-8'))
    rows = []
    for entry in dump['entries']:
        if not entry['active_count'] or entry['status'] != 'untranslated':
            continue
        name = entry['id']
        kind, reason = category(int(name[1:]))
        active = [item['pointer'] for item in entry['occurrences']
                  if item['file'] == 'src/Questena.js']
        rows.append((name, entry['original'], kind, reason,
                     entry['active_count'], ';'.join(active)))
    output = HERE / 'dump' / 'remaining_review.tsv'
    with output.open('w', encoding='utf-8', newline='') as file:
        writer = csv.writer(file, delimiter='\t')
        writer.writerow(('id', 'original', 'category', 'reason', 'active_count', 'ink_pointers'))
        writer.writerows(rows)
    counts = Counter(row[2] for row in rows)
    print(f'{len(rows)} reviewed active strings -> {output}')
    print('Categories:', ', '.join(f'{key}={value}' for key, value in sorted(counts.items())))


if __name__ == '__main__':
    main()
