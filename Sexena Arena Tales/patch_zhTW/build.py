"""Rebuild the game's ASAR with reviewed Traditional Chinese text and a sans font."""
import os
import json
import re
import shutil
from pathlib import Path

from asar_io import get, pack, read


ROOT = Path(os.environ['SEXENA_GAME_ROOT']).resolve()
HERE = Path(__file__).resolve().parent
ACTIVE = ROOT / 'resources/app.asar'
BACKUP = ROOT / 'resources/app.original.asar'
FONT = Path('C:/Windows/Fonts/NotoSansTC-VF.ttf')


def main():
    if not BACKUP.exists():
        shutil.copy2(ACTIVE, BACKUP)
    data, tree, base = read(BACKUP)
    mapping = json.loads((HERE / 'strings.json').read_text(encoding='utf-8'))
    for addition in sorted(HERE.glob('strings_*.json')):
        overlap = set(mapping) & set(json.loads(addition.read_text(encoding='utf-8')))
        if overlap:
            raise ValueError(f'Duplicate translation keys in {addition.name}: {sorted(overlap)}')
        mapping.update(json.loads(addition.read_text(encoding='utf-8')))
    path = 'src/Questena.js'
    source = get(data, tree, base, path).decode('utf-8-sig')
    start = source.index('{')
    story, consumed = json.JSONDecoder(strict=False).raw_decode(source[start:])
    seen = set()

    def translate(obj):
        if isinstance(obj, str) and obj.startswith('^'):
            original = obj[1:]
            if original in mapping:
                seen.add(original)
                return '^' + mapping[original]
        if isinstance(obj, list):
            return [translate(item) for item in obj]
        if isinstance(obj, dict):
            return {key: translate(value) for key, value in obj.items()}
        return obj

    story = translate(story)
    missing = set(mapping) - seen
    if missing:
        raise ValueError('Translation keys absent from compiled story: ' + repr(sorted(missing)))
    compiled = (source[:start] + json.dumps(story, ensure_ascii=False, separators=(',', ':'))
                + source[start + consumed:]).encode('utf-8')
    changes = {path: compiled}

    html_path = 'src/index.html'
    html = get(data, tree, base, html_path).decode('utf-8-sig')
    replacements = {
        'All depicted individuals are adults over the age of 21': '所有登場人物均已年滿二十一歲。',
        '>Sound On<': '>音效開啟<',
        '>Save<': '>儲存<',
        '>Load<': '>讀取<',
        '>Restart<': '>重新開始<',
        '>Quit<': '>離開遊戲<',
        'value="Save"': 'value="儲存"',
        'Game Saved!': '遊戲已儲存！',
        '<span class="barname">EnemyHP</span>': '<span class="barname">敵方生命值</span>',
        'barname="EnemyHP"': 'barname="敵方生命值"',
        'value="Ok"': 'value="確定"',
        "value='Load'": "value='讀取'",
    }
    for old, new in replacements.items():
        if old not in html:
            raise ValueError('HTML string absent: ' + old)
        html = html.replace(old, new)
    changes[html_path] = html.encode('utf-8')

    save_ui_path = 'src/save-load-ui.js'
    save_ui = get(data, tree, base, save_ui_path).decode('utf-8-sig')
    save_ui_replacements = {
        'Save is only enabled during gameplay choices': '只能在出現劇情選項時儲存遊戲。',
        'Save/Load/Restart module could not load.  Contact support through steam for assitance.':
            '無法載入儲存、讀取及重新開始模組。請透過 Steam 聯絡客服尋求協助。',
        'confirm("Are you sure?")': 'confirm("確定要離開遊戲嗎？")',
        '>Load</button>': '>讀取</button>',
        '<div>No save games found</div>': '<div>找不到存檔</div>',
        "'Sexena - Save '": "'Sexena－存檔 '",
    }
    for old, new in save_ui_replacements.items():
        if old not in save_ui:
            raise ValueError('Save UI string absent: ' + old)
        save_ui = save_ui.replace(old, new)
    changes[save_ui_path] = save_ui.encode('utf-8')

    achievement_path = 'src/achievements/achievement.js'
    achievement_script = get(data, tree, base, achievement_path).decode('utf-8-sig')
    achievement_text = json.loads((HERE / 'achievement_text.json').read_text(encoding='utf-8'))
    for old, new in achievement_text.items():
        if old not in achievement_script:
            raise ValueError('Achievement string absent: ' + old)
        achievement_script = achievement_script.replace(old, new)
    changes[achievement_path] = achievement_script.encode('utf-8')

    script_replacements = {
        'src/dbcalls.js': {
            'Saving could not be enabled on this machine.': '無法在這部電腦上啟用存檔功能。',
            'This will overwrite your save, continue?': '這會覆蓋現有存檔，確定要繼續嗎？',
        },
        'src/reader.js': {
            'could not load game, record does not exist': '無法讀取遊戲：找不到存檔紀錄。',
            'No game data exists for this slot!': '這個欄位沒有遊戲存檔！',
            "The file API isn't supported on this browser yet.": '這個瀏覽器尚未支援檔案功能。',
            "Couldn't find the fileinput element.": '找不到檔案選取欄位。',
            "This browser doesn't seem to support the `files` property of file inputs.":
                '這個瀏覽器似乎不支援檔案選取功能。',
            "Please select a file before clicking 'Load'": '請先選擇檔案，再按「讀取」。',
        },
    }
    for script_path, replacements in script_replacements.items():
        script = get(data, tree, base, script_path).decode('utf-8-sig')
        for old, new in replacements.items():
            if old not in script:
                raise ValueError(f'{script_path} string absent: {old}')
            script = script.replace(old, new)
        changes[script_path] = script.encode('utf-8')

    css_path = 'src/css/fonts.css'
    css = get(data, tree, base, css_path).decode('utf-8-sig')
    css += '''\n/* Traditional Chinese: bundled Noto Sans TC, with clear strokes at game UI sizes. */
@font-face { font-family: 'Sexena TC'; src: url('fonts/notosanstc-vf.ttf') format('truetype'); font-style: normal; font-weight: 100 900; }
body, button, input, textarea, select, #story, #choices, #ui, #esccontainer {
    font-family: 'Sexena TC', 'Microsoft JhengHei', sans-serif !important;
}
/* The title PNG embeds an English age notice. The translated notice is HTML text above it. */
img[src='ui/title.png'] {
    -webkit-clip-path: polygon(0 0, 100% 0, 100% 72%, 34% 72%, 34% 100%, 0 100%);
    clip-path: polygon(0 0, 100% 0, 100% 72%, 34% 72%, 34% 100%, 0 100%);
}
'''
    changes[css_path] = css.encode('utf-8')
    if not FONT.is_file():
        raise FileNotFoundError(FONT)
    changes['src/css/fonts/notosanstc-vf.ttf'] = FONT.read_bytes()

    temporary = ACTIVE.with_suffix('.zhTW.tmp')
    pack(BACKUP, temporary, changes)
    temporary.replace(ACTIVE)
    print(f'ASAR verified: {len(changes)} files changed, {len(seen)} reviewed story strings translated.')


if __name__ == '__main__':
    main()

