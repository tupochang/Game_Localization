import hashlib
import json
import pathlib
import shutil

HERE = pathlib.Path(__file__).resolve().parent
GAME = pathlib.Path(r"D:\SteamLibrary\steamapps\common\Thora")
BACKUPS = GAME / "translation"
PAYLOAD = HERE / "payload"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if not (GAME / "Game.exe").is_file():
        raise SystemExit(f"Game not found: {GAME}")
    candidates = set()
    for backup in BACKUPS.glob("backup*"):
        if not backup.is_dir():
            continue
        for old in backup.rglob("*"):
            if not old.is_file():
                continue
            rel = old.relative_to(backup)
            if rel.parts[0] == "www":
                target = GAME / rel
            elif len(rel.parts) == 1 and rel.suffix == ".json":
                target = GAME / "www" / "data" / rel
            else:
                continue
            if target.is_file() and sha(old) != sha(target):
                candidates.add(target.relative_to(GAME))
    candidates.add(pathlib.Path("www/img/titles1/Champions of Thora.rpgmvp"))
    if PAYLOAD.exists():
        shutil.rmtree(PAYLOAD)
    manifest = []
    for rel in sorted(candidates):
        src = GAME / rel
        dest = PAYLOAD / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        manifest.append({"path": rel.as_posix(), "sha256": sha(dest), "bytes": dest.stat().st_size})
    (HERE / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{len(manifest)} files, {sum(x['bytes'] for x in manifest)} bytes")


if __name__ == "__main__":
    main()
