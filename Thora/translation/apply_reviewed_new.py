import collections, datetime, hashlib, json, openpyxl, pathlib, re, shutil

root=pathlib.Path(__file__).resolve().parents[1]
folder=root/'translation'
workbook=folder/'托拉的勇者_劇情翻譯_NEW.xlsx'
book=openpyxl.load_workbook(workbook,read_only=True,data_only=True)
data=root/'www/data'
objects={};requests={};checks=[]
controls=re.compile(r'\\(?:[VNPCIG]\[\d+\]|[VNPCIG]|[{}.$|!><^\\])|%\d+',re.I)

def target_file(src):
    if not re.fullmatch(r'(?:Map\d{3}|Actors|Armors|Classes|Difficulties|Enemies|Items|Skills|States|System|Weapons)\.json',src):
        raise ValueError(f'Unexpected data file: {src}')
    return data/src
def obj(src):
    if src not in objects:objects[src]=json.loads(target_file(src).read_text(encoding='utf-8'))
    return objects[src]
def parse(key):
    parts=[]
    for token in re.findall(r'\[\d+\]|[^.\[\]]+',str(key)):
        parts.append(int(token[1:-1]) if token.startswith('[') else int(token) if token.isdigit() else token)
    return parts
def at(container,parts):
    for part in parts:container=container[part]
    return container
def stage(src,key,target,english,row):
    path=tuple(parse(key));container=obj(src)
    parent=at(container,path[:-1]);current=parent[path[-1]]
    if not isinstance(current,str):raise ValueError(f'Expected string at {src}:{key} row {row}')
    if not isinstance(target,str):raise ValueError(f'Expected translation string at row {row}')
    if sorted(controls.findall(str(english or '')))!=sorted(controls.findall(target)):
        raise ValueError(f'Control code mismatch at row {row}')
    lookup=(src,path)
    if lookup in requests and requests[lookup]!=target:raise ValueError(f'Conflicting translations at {src}:{key}')
    requests[lookup]=target
    checks.append((src,path,target,row))

for rowno,row in enumerate(list(book.worksheets[0].values)[1:],2):
    src,_,event_id,_,page,index,kind,choice,english,target,_=row
    if src=='System.json':
        stage(src,index,target,english,rowno);continue
    if not re.fullmatch(r'Map\d{3}\.json',str(src)):raise ValueError(f'Unexpected story source row {rowno}')
    command=obj(src)['events'][int(event_id)]['pages'][int(page)]['list'][int(index)]
    code={'對話':401,'捲動文字':405,'選項':102}[kind]
    if command['code']!=code:raise ValueError(f'Event command mismatch row {rowno}')
    p=f'events[{int(event_id)}].pages[{int(page)}].list[{int(index)}].parameters[0]'
    if code==102:p+=f'[{int(choice)}]'
    stage(src,p,target,english,rowno)

for sheet in book.worksheets[1:]:
    for rowno,row in enumerate(list(sheet.values)[1:],2):
        category,src,_,field,english,target,_,key,_=row
        if str(src).endswith('.json'):
            stage(src,key,target,english,f'{sheet.title}!{rowno}')
        else:
            # These labels live in JavaScript or in the encrypted title image.
            # Their existing translation is verified below; no unrelated code is rewritten.
            if not isinstance(target,str) or not target:raise ValueError(f'Empty special asset row {sheet.title}!{rowno}')

# Verify special UI entries from the workbook against the installed code/assets.
plugins=(root/'www/js/plugins.js').read_text(encoding='utf-8')
difficulty=(root/'www/js/plugins/SSG_DifficultySetting.js').read_text(encoding='utf-8')
windows=(root/'www/js/rpg_windows.js').read_text(encoding='utf-8')
for plugin,phrase in [('SRD_FullscreenToggleOption','"Option Name":"全螢幕"'),('YEP_FpsSynchOption','"Command Name":"同步螢幕幀率"')]:
    if phrase not in plugins:raise ValueError(f'UI plugin translation absent: {plugin}')
if "this.addCommand('難度', 'difficulty')" not in difficulty:raise ValueError('Difficulty label absent')
if "return value ? '開' : '關';" not in windows:raise ValueError('Option state translation absent')
title=root/'www/img/titles1/Champions of Thora.rpgmvp'
encrypted=title.read_bytes()
key=bytes.fromhex(obj('System.json')['encryptionKey'])
png=bytearray(encrypted[16:40])
for i in range(16):png[i]^=key[i]
if bytes(png[:8])!=b'\x89PNG\r\n\x1a\n' or int.from_bytes(png[16:20],'big')!=816 or int.from_bytes(png[20:24],'big')!=624:
    raise ValueError('Localized title image missing or wrong dimensions')

changed=[]
for (src,path),target in requests.items():
    parent=at(obj(src),path[:-1])
    if parent[path[-1]]!=target:changed.append(src)
    parent[path[-1]]=target
changed_files=sorted(set(changed))
backup=folder/('backup_before_NEW_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
backup.mkdir()
manifest={'workbook_sha256':hashlib.sha256(workbook.read_bytes()).hexdigest(),'changed_files':changed_files,'translations_checked':len(checks)}
for src in changed_files:shutil.copy2(target_file(src),backup/src)
(backup/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
for src in changed_files:
    file=target_file(src);tmp=file.with_suffix('.json.tmp')
    tmp.write_text(json.dumps(objects[src],ensure_ascii=False,separators=(',',':')),encoding='utf-8')
    tmp.replace(file)
for src,path,target,row in checks:
    actual=at(json.loads(target_file(src).read_text(encoding='utf-8')),path)
    if actual!=target:raise RuntimeError(f'Post-write mismatch at {src}:{path} row {row}')
print(json.dumps({'workbook_rows':len(checks),'unique_targets':len(requests),'changed_files':len(changed_files),'backup':str(backup),'files':changed_files},ensure_ascii=True))
