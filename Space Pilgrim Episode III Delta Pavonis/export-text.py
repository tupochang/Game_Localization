"""Export Episode III text from the original Steam installation."""
import argparse
from pathlib import Path
import runpy


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("game", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    shared = Path(__file__).resolve().parents[1] / "Space Pilgrim Episode One Alpha Centauri" / "export-text.py"
    tools = runpy.run_path(str(shared))
    archive = args.game / "Game.rgss3a.title-menu-test.bak"
    if not archive.exists():
        archive = args.game / "Game.rgss3a"

    inventory = tools["Inventory"]()
    decode = tools["decode"]
    files = []
    for name, raw in tools["archive_files"](archive):
        files.append(name)
        reader = tools["Marshal"](raw)
        data = reader.value()
        if reader.pos != len(raw):
            raise ValueError(f"Unparsed data in {name}")
        if name.endswith("\\Scripts.rvdata2"):
            for script_id, section, compressed in data:
                section = decode(section)
                code = decode(tools["zlib"].decompress(compressed))
                inventory.ruby(name, f"{section} [{script_id}]", code, section)
        else:
            inventory.visit(name, data)

    assets = "圖像與外部文字"
    for filename in ("Credits.txt", "Game.ini"):
        for line_number, line in enumerate(decode((args.game / filename).read_bytes()).splitlines(), 1):
            if filename == "Credits.txt":
                inventory.add(assets, "製作名單", filename, f"L{line_number}", line)
            elif line.startswith("Title="):
                inventory.add(assets, "視窗標題", filename, f"L{line_number}", line[6:])
    manifest = Path(__file__).with_name("image-text.tsv")
    for line in manifest.read_text(encoding="utf-8").splitlines():
        filename, location, value = line.split("\t")
        inventory.add(assets, "圖像文字", filename, location, value.replace(r"\n", "\n"))

    args.output.write_text(tools["json"].dumps({"files": files, "sheets": inventory.sheets},
                                               ensure_ascii=False), encoding="utf-8")
    print(f"{len(files)} data files")
    for name, rows in inventory.sheets.items():
        print(name, len(rows))


if __name__ == "__main__":
    main()
