"""Extract translatable text and review candidates from the original RGSS3 data."""
import argparse
from collections import Counter
from dataclasses import dataclass, field
import json
from pathlib import Path
import re
import struct
import zlib


def archive_files(path, include=lambda name: name.lower().endswith(".rvdata2")):
    data = path.read_bytes()
    if data[:8] != b"RGSSAD\0\3":
        raise ValueError("Expected an RGSS3 archive")
    header_key = (struct.unpack_from("<I", data, 8)[0] * 9 + 3) & 0xffffffff
    name_key = header_key.to_bytes(4, "little")
    pos = 12
    while True:
        offset, size, key, name_size = (n ^ header_key for n in struct.unpack_from("<4I", data, pos))
        if not offset:
            return
        pos += 16
        name = bytes(b ^ name_key[i % 4] for i, b in enumerate(data[pos:pos + name_size])).decode()
        pos += name_size
        if not include(name):
            continue
        decoded = bytearray(data[offset:offset + size])
        for i in range(0, size, 4):
            for j, b in enumerate(key.to_bytes(4, "little")[:size - i]):
                decoded[i + j] ^= b
            key = (7 * key + 3) & 0xffffffff
        yield name, bytes(decoded)


@dataclass
class Object:
    name: str
    fields: dict = field(default_factory=dict)


class Marshal:
    def __init__(self, data):
        if data[:2] != b"\x04\x08":
            raise ValueError("Expected Ruby Marshal 4.8")
        self.data = data
        self.pos = 2
        self.objects = []
        self.symbols = []

    def read(self, size):
        result = self.data[self.pos:self.pos + size]
        self.pos += size
        if len(result) != size or size < 0:
            raise ValueError("Truncated Marshal value")
        return result

    def number(self):
        n = int.from_bytes(self.read(1), "little", signed=True)
        if n > 4:
            return n - 5
        if n < -4:
            return n + 5
        return int.from_bytes(self.read(abs(n)), "little", signed=n < 0)

    def blob(self):
        return self.read(self.number())

    def register(self, obj):
        self.objects.append(obj)
        return obj

    def pairs(self):
        for _ in range(self.number()):
            key = self.value()
            yield key, self.value()

    def value(self):
        tag = self.read(1)
        if tag == b"0":
            return None
        if tag in (b"T", b"F"):
            return tag == b"T"
        if tag == b"i":
            return self.number()
        if tag == b'"':
            return self.register(self.blob())
        if tag == b"@":
            return self.objects[self.number()]
        if tag == b":":
            name = self.blob().decode()
            self.symbols.append(name)
            return name
        if tag == b";":
            return self.symbols[self.number()]
        if tag == b"I":
            obj = self.value()
            list(self.pairs())
            return obj
        if tag == b"[":
            items = self.register([])
            items.extend(self.value() for _ in range(self.number()))
            return items
        if tag in (b"{", b"}"):
            items = self.register({})
            items.update(self.pairs())
            if tag == b"}":
                self.value()
            return items
        if tag in (b"o", b"S"):
            obj = self.register(Object(self.value()))
            obj.fields.update(self.pairs())
            return obj
        if tag == b"u":
            obj = self.register(Object(self.value()))
            self.blob()
            return obj
        if tag == b"f":
            return self.register(float(self.blob().split(b"\0", 1)[0]))
        if tag == b"l":
            negative = self.read(1) == b"-"
            value = int.from_bytes(self.read(self.number() * 2), "little")
            return self.register(-value if negative else value)
        raise ValueError(f"Unsupported Marshal tag {tag!r} at offset {self.pos - 1}")


def decode(data):
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return data.decode("cp1252")


def has_text(value):
    # Punctuation-only responses such as "..." and "!" are retained in event text.
    return bool(value.strip() and not re.fullmatch(r"[\s\u3400-\u9fff\uf900-\ufaff\u3000-\u303f\uff00-\uffef]+", value))


RUBY_TOKEN = re.compile(
    r"""\#[^\r\n]*|"(?:\\.|\#\{[^}\n]*\}|[^"\\])*"|'(?:\\.|[^'\\])*'|%[qQ](?:\{[^}]*\}|\[[^\]]*\]|\([^)]*\)|<[^>]*>)""",
    re.DOTALL,
)
DISPLAY_SCRIPT = re.compile(
    r"\b(?:draw_text(?:_ex)?|add_command|set_text|set_help_text|"
    r"add_text|notify|add_message|add_popup|popup|title|description)\b"
)


class Inventory:
    def __init__(self):
        self.sheets = {}

    def add(self, tab, kind, file, location, value, translation=None, context=None):
        if not has_text(value):
            return
        rows = self.sheets.setdefault(tab, [])
        prefix = {"劇情事件": "EV", "資料庫與系統": "DB", "腳本待核對": "SC", "圖像與外部文字": "AS"}[tab]
        rows.append([f"{prefix}-{len(rows) + 1:05}", kind, value, translation, file, location, context])

    def ruby(self, file, location, source, section=None):
        for token in RUBY_TOKEN.finditer(source):
            raw = token.group()
            if raw.startswith("#"):
                continue
            content = raw[3:-1] if raw.startswith("%") else raw[1:-1]
            if not re.search(r"[^\W_]|[!?…]", content) or not has_text(content):
                continue
            start = source.rfind("\n", 0, token.start()) + 1
            end = source.find("\n", token.end())
            line = source[start:end if end >= 0 else len(source)].strip()
            line_no = source.count("\n", 0, token.start()) + 1
            likely = section == "Vocab" or DISPLAY_SCRIPT.search(line[:line.find(raw)])
            self.add("腳本待核對", "介面文字候選" if likely else "字串候選",
                     file, f"{location} / L{line_no}:{token.start() - start + 1}", content,
                     context=line[:1000])

    def events(self, file, location, commands):
        i = 0
        while i < len(commands):
            command = commands[i].fields
            code, params = command["@code"], command["@parameters"]
            key = f"{location}[{i}] / {code}"
            if code in (101, 105, 108, 355):
                lines = [decode(params[0])] if code in (108, 355) else []
                continuation = {101: 401, 105: 405, 108: 408, 355: 655}[code]
                end = i + 1
                while end < len(commands) and commands[end].fields["@code"] == continuation:
                    lines.append(decode(commands[end].fields["@parameters"][0]))
                    end += 1
                span = f"{key} / 至索引 {end - 1}"
                if code == 355:
                    self.ruby(file, span, "\n".join(lines))
                elif lines:
                    tab = "腳本待核對" if code == 108 else "劇情事件"
                    kind = {101: "對話", 105: "捲動文字", 108: "事件註解待核對"}[code]
                    portrait = decode(params[0]) if code == 101 else ""
                    self.add(tab, kind, file, span, "\n".join(lines),
                             context=f"肖像 {portrait} / {params[1]}" if portrait else None)
                i = end
                continue
            if code == 102:
                for n, choice in enumerate(params[0]):
                    self.add("劇情事件", "選項", file, f"{key} / 選項 {n}", decode(choice))
            elif code == 402:
                self.add("劇情事件", "選項分支標籤", file, key, decode(params[1]))
            elif code == 320 or code == 324 or code == 325:
                self.add("劇情事件", "角色文字變更", file, key, decode(params[1]))
            elif code == 205:
                self.visit(file, params[1], f"{key} / 移動路線")
            elif code == 111 and params[0] == 12:
                self.ruby(file, key, decode(params[-1]))
            elif code == 122 and params[3] == 4:
                self.ruby(file, key, decode(params[-1]))
            else:
                for n, param in enumerate(params):
                    if isinstance(param, bytes) and param.strip():
                        self.add("腳本待核對", "事件參數待核對", file, f"{key} / 參數 {n}", decode(param))
            i += 1

    @staticmethod
    def is_database_text(file, location):
        editor_files = ("Animations.rvdata2", "CommonEvents.rvdata2", "Tilesets.rvdata2", "Troops.rvdata2")
        internal_fields = (".@bgm.", ".@bgs.", ".@me.", ".@se.", ".@events[", ".@sounds[",
                           ".@title_bgm.", ".@battle_bgm.", ".@boat.", ".@ship.", ".@airship.")
        return not file.endswith(editor_files) and not any(field in location for field in internal_fields)

    def visit(self, file, value, location="$", field_name=""):
        if isinstance(value, Object):
            for key, item in value.fields.items():
                item_path = f"{location}.{key}"
                if key == "@list" and isinstance(item, list) and item and isinstance(item[0], Object):
                    if item[0].name == "RPG::EventCommand":
                        self.events(file, item_path, item)
                        continue
                if value.name == "RPG::MoveCommand" and key == "@parameters" and value.fields.get("@code") == 45:
                    self.ruby(file, item_path, decode(item[0]))
                    continue
                self.visit(file, item, item_path, key)
        elif isinstance(value, (list, dict)):
            for key, item in (enumerate(value) if isinstance(value, list) else value.items()):
                self.visit(file, item, f"{location}[{key}]", field_name)
        elif isinstance(value, bytes):
            text = decode(value)
            if not text.strip():
                return
            if field_name in SYSTEM_FIELDS and self.is_database_text(file, location):
                translated = {"New Game": "開始新遊戲", "Load": "繼續遊戲", "Quit": "離開遊戲"}.get(text) if "@terms.@commands" in location else None
                self.add("資料庫與系統", "資料庫文字", file, location, text, translated)
            else:
                self.add("腳本待核對", "資料欄位待核對", file, location, text)


SYSTEM_FIELDS = set("""
@name @nickname @description @display_name @game_title @currency_unit
@message1 @message2 @message3 @message4 @basic @params @etypes @commands
@elements @skill_types @weapon_types @armor_types
""".split())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("game", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    backup = args.game / "Game.rgss3a.title-menu-test.bak"
    archive = backup if backup.exists() else args.game / "Game.rgss3a"
    inv = Inventory()
    files = []
    for name, raw in archive_files(archive):
        files.append(name)
        loader = Marshal(raw)
        root = loader.value()
        if loader.pos != len(raw):
            raise ValueError(f"Unparsed data in {name}")
        if name.endswith("\\Scripts.rvdata2"):
            for script_id, section, compressed in root:
                inv.ruby(name, f"{decode(section)} [{script_id}]", decode(zlib.decompress(compressed)), decode(section))
        else:
            inv.visit(name, root)

    inv.add("圖像與外部文字", "標題圖", r"Graphics\Titles1\PilgrimTitlePNG.png", "主標題", "SPACE PILGRIM")
    inv.add("圖像與外部文字", "標題圖", r"Graphics\Titles1\PilgrimTitlePNG.png", "副標題", "EPISODE I: ALPHA CENTAURI")
    inv.add("圖像與外部文字", "結束畫面", r"Graphics\System\GameOver.png", "畫面中央", "GAME OVER")
    inv.add("圖像與外部文字", "開場圖", r"Graphics\Pictures\Title.png", "開發商標誌", "Pilgrim Adventures")
    for n, label in enumerate(("OPEN", "OPEN", "MOTEL", "DINER", "BAR", "EXIT", "HOTEL",
                              "CLUB", "SHOP", "Café", "INTERNET CAFE", "GAS", "BAR"), 1):
        inv.add("圖像與外部文字", "圖像招牌待核對", r"Graphics\Characters\neonsigns.png",
                f"招牌 {n}", label, context="圖形素材，遊戲內使用位置待確認")
    for n, label in ((2, "Sandwiches"), (3, "Bola-fusion\nFuturistic drinks"),
                     (7, "Always Beauty"), (8, "AVERS CONSULT"), (11, "Always Beauty")):
        inv.add("圖像與外部文字", "廣告圖待核對", r"Graphics\Characters\!$billboards.png",
                f"廣告格 {n}（由左至右、由上至下）", label,
                context="已辨認的字樣，部分細字因原圖解析度待確認")
    for asset, labels in {
        "ModernDay_TileB": ("STOP", "POPCORN"),
        "ModernDay_TileC": ("TOYS",),
        "ModernDay_TileD": ("TAXI", "ATM", "NEWS", "WANTED", "No warzone"),
        "TileD": ("ARCADE", "ATM"),
        "TileE": ("COOL",),
    }.items():
        for label in labels:
            inv.add("圖像與外部文字", "圖塊字樣待核對", rf"Graphics\Tilesets\{asset}.png",
                    f"字樣 {label}", label, context="圖形素材，遊戲內使用位置待確認")
    for n, line in enumerate(decode((args.game / "Credits.txt").read_bytes()).splitlines(), 1):
        inv.add("圖像與外部文字", "製作名單", "Credits.txt", f"L{n}", line)
    for n, line in enumerate(decode((args.game / "Game.ini").read_bytes()).splitlines(), 1):
        if line.startswith("Title="):
            inv.add("圖像與外部文字", "視窗標題", "Game.ini", f"L{n}", line[6:])

    args.output.write_text(json.dumps({"files": files, "sheets": inv.sheets}, ensure_ascii=False), encoding="utf-8")
    print(f"{len(files)} data files")
    for tab, rows in inv.sheets.items():
        print(tab, len(rows), dict(Counter(row[1] for row in rows)))


if __name__ == "__main__":
    main()
