import collections, datetime, hashlib, json, pathlib, shutil
import openpyxl

root=pathlib.Path(__file__).resolve().parents[1]
folder=root/'translation'
source=folder/'托拉的勇者_劇情翻譯.xlsx'
book=openpyxl.load_workbook(source,read_only=True,data_only=True)
rows=list(book.active.values)
expected=['來源檔案','地圖名稱','事件 ID','事件名稱','頁面(0起)','指令索引(0起)','類型','選項索引','英文原文','繁體中文','狀態']
if list(rows[0])!=expected:raise RuntimeError('Workbook columns changed')
edits=collections.defaultdict(list)
corrections={('Map002.json',2,0,19):'',('Map002.json',2,0,62):''}
for rownum,row in enumerate(rows[1:],2):
    src,_,eid,_,page,index,kind,choice,original,target,_=row
    if target is None:raise RuntimeError(f'Blank translation at row {rownum}')
    if src=='System.json': key=(src,str(index))
    else:key=(src,int(eid),int(page),int(index))
    if key in corrections:target=corrections[key]
    edits[src].append((rownum,key,kind,choice,original,target))

objects={}
for src,records in edits.items():
    current=root/'www/data'/src
    baseline=folder/'backup_original'/src
    obj=json.loads(current.read_text(encoding='utf-8'))
    old=json.loads(baseline.read_text(encoding='utf-8')) if baseline.exists() else obj
    for rownum,key,kind,choice,original,target in records:
        if src=='System.json':
            field=key[1]
            if field=='gameTitle': location=('gameTitle',)
            else:location=('terms','commands',int(field.split('.')[-1]))
            def get(o):
                for part in location:o=o[part]
                return o
            oldval=get(old)
            currentval=get(obj)
            if oldval!=original and currentval!=original and currentval!=target:raise RuntimeError(f'Source mismatch row {rownum}')
            if len(location)==1:obj[location[0]]=target
            else:obj['terms']['commands'][location[2]]=target
        else:
            _,eid,page,index=key
            cmd=obj['events'][eid]['pages'][page]['list'][index]
            original_cmd=old['events'][eid]['pages'][page]['list'][index]
            code={'對話':401,'捲動文字':405,'選項':102}[kind]
            if cmd['code']!=code:raise RuntimeError(f'Command mismatch row {rownum}')
            oldval=original_cmd['parameters'][0][int(choice)] if code==102 else original_cmd['parameters'][0]
            currentval=cmd['parameters'][0][int(choice)] if code==102 else cmd['parameters'][0]
            if oldval!=original and currentval!=original and currentval!=target:raise RuntimeError(f'Source mismatch row {rownum}: {currentval!r}')
            if code==102:cmd['parameters'][0][int(choice)]=target
            else:cmd['parameters'][0]=target
    objects[src]=obj

stamp=datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
backup=folder/f'backup_before_full_{stamp}'
backup.mkdir()
manifest={'workbook_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'files':{},'corrections':list(map(str,corrections))}
for src in objects:
    file=root/'www/data'/src
    shutil.copy2(file,backup/src)
    manifest['files'][src]=hashlib.sha256(file.read_bytes()).hexdigest()
(backup/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
for src,obj in objects.items():
    file=root/'www/data'/src
    tmp=file.with_suffix('.json.tmp')
    tmp.write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
    tmp.replace(file)
for src,records in edits.items():
    obj=json.loads((root/'www/data'/src).read_text(encoding='utf-8'))
    for rownum,key,kind,choice,_,target in records:
        if src=='System.json':
            field=key[1]
            actual=obj['gameTitle'] if field=='gameTitle' else obj['terms']['commands'][int(field.split('.')[-1])]
        else:
            _,eid,page,index=key
            cmd=obj['events'][eid]['pages'][page]['list'][index]
            actual=cmd['parameters'][0][int(choice)] if kind=='選項' else cmd['parameters'][0]
        if actual!=target:raise RuntimeError(f'Verification failed row {rownum}')
print(json.dumps({'files':len(objects),'lines':sum(map(len,edits.values())),'backup':str(backup),'corrected_duplicate_lines':len(corrections)},ensure_ascii=True))
