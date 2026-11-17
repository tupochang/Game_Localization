
import argparse, collections, hashlib, json, re, zipfile
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('game',type=Path)
p.add_argument('backup',type=Path)
p.add_argument('output',type=Path)
p.add_argument('inventory',type=Path)
args=p.parse_args()
def load(f):return json.loads(f.read_text(encoding='utf-8-sig'))
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
manifest=load(args.backup/'manifest.json')
sheet_names=['劇情與事件','資料庫與系統','外掛介面']
sheets={name:[] for name in sheet_names}
map_index=load(args.game/'data/MapInfos.json')
maps={f'Map{x["id"]:03}.json': x['name'] for x in map_index if x}
placeholder=re.compile(r'\\[A-Za-z]+(?:\[[^\]\n]*\]|<[^>\n]*>)?|\\[{}$.|!><^\\]|%[0-9]+')
def pointer(path):
    return '/'+ '/'.join(str(x).replace('~','~0').replace('/','~1') for x in path)
def row(tab,kind,old,new,file,path,context):
    if not isinstance(old,str) or not old.strip():return
    status='待校對' if old!=new else '保留原文'
    rows=sheets[tab]
    rows.append([f'{sheet_names.index(tab)+1}-{len(rows)+1:04}',kind,old,new,status,'',file,pointer(path),context])
def read_plugins(path):
    s=path.read_text(encoding='utf-8-sig')
    return json.loads(s[s.index('['):s.rindex(']')+1])
def walk(x,y,path=(),context='',command=None):
    assert type(x)==type(y),(file,path)
    if isinstance(x,dict):
        assert x.keys()==y.keys(),(file,path)
        if 'code' in x and isinstance(x.get('parameters'),list):
            command=x['code']
        elif x.get('name') and any(k in x for k in ('pages','list','id')):
            context=f'{context} / {x["name"]}' if context else x['name']
        for k,value in x.items():walk(value,y[k],path+(k,),context,command)
    elif isinstance(x,list):
        assert len(x)==len(y),(file,path)
        for i,(a,b) in enumerate(zip(x,y)):
            child_context=context
            if path and path[-1]=='pages':child_context+=f' / 第 {i+1} 頁'
            walk(a,b,path+(i,),child_context,command)
    elif isinstance(x,str):
        if plugin and x!=y and x.startswith(('{','[','"')):
            try:
                a,b=json.loads(x),json.loads(y)
            except ValueError:
                a,b=x,y
            if (a,b)!=(x,y):
                walk(a,b,path+('@JSON',),context,command)
                return
        is_event=command in (101,102,320,324,325,401,402,405) and 'parameters' in path
        if is_event:
            kind={101:'說話者',102:'選項',402:'選項分支',401:'對話',405:'捲動文字'}.get(command,'名稱變更')
            if command==101 and path[-1]!=4:return
            if (x!=y or re.search(r'[A-Za-z]',placeholder.sub('',x))) and x.strip():
                row(sheet_names[0],kind,x,y,file,path,context)
        elif x!=y:
            if path==('advanced','fallbackFonts'):return
            if path[-1]=='note' and not plugin:
                original_lines=x.split('\n')
                localized_lines=y.split('\n')
                if len(original_lines)==len(localized_lines):
                    for i,(source,target) in enumerate(zip(original_lines,localized_lines)):
                        if source!=target:
                            row(sheet_names[1],'角色／圖鑑附註',source,target,file,path+('@line',i+1),context)
                    return
            if plugin:
                kind='外掛參數'
            else:
                kind={'displayName':'地圖名稱','note':'角色／圖鑑附註','description':'說明','name':'名稱'}.get(path[-1], '系統詞彙' if file.endswith('System.json') else '資料庫文字')
            tab=sheet_names[2 if plugin else 0 if kind=='地圖名稱' else 1]
            row(tab,kind,x,y,file,path,context)
    else:
        assert x==y,(file,path)

for item in manifest:
    file=item['path']
    a,b=args.backup/file,args.game/file
    assert sha(a)==item['original_sha256'] and sha(b)==item['localized_sha256'],file
    plugin=file=='js/plugins.js'
    if plugin:
        for i,(x,y) in enumerate(zip(read_plugins(a),read_plugins(b),strict=True)):
            if x!=y: walk(x['parameters'],y['parameters'],(i,'parameters'),x['name'])
    elif file.endswith('.json'):
        src,dst=load(a),load(b)
        walk(src,dst,context=maps.get(a.name,''))
args.inventory.write_text(json.dumps(sheets,ensure_ascii=False),encoding='utf-8')
with zipfile.ZipFile(args.output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    directory=Path(__file__).parent/'patch'
    for name in ('patch.ps1','README.md'):
        z.write(directory/name,name)
    z.writestr('manifest.json',json.dumps(manifest,indent=2))
    for item in manifest:
        file=item['path']
        z.write(args.game/file,'payload/'+file)
print('Workbook rows:', {k: len(v) for k,v in sheets.items()})
print('Patch files:',len(manifest),'zip bytes:',args.output.stat().st_size)
