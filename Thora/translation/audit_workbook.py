import json, openpyxl, pathlib, collections, re
root=pathlib.Path(__file__).resolve().parents[1]
book=openpyxl.load_workbook(root/'translation/托拉的勇者_劇情翻譯.xlsx',read_only=True,data_only=True)
sheet=book.active
rows=list(sheet.values)
stats=collections.Counter()
problems=[]
sample=[]
data=root/'www/data'
cache={}
for rowno,row in enumerate(rows[1:],2):
    a=list(row)+[None]*11
    src,mapname,eid,ename,page,index,kind,choice,original,target,status=a[:11]
    stats['rows']+=1
    if target is not None and str(target).strip(): stats['translated']+=1
    else: stats['blank']+=1
    if target==original:stats['same_as_english']+=1
    if isinstance(target,str) and re.search(r'[\u4e00-\u9fff]',target):stats['has_han']+=1
    stats['status:'+str(status)]+=1
    if src not in cache:
        p=data/str(src)
        if not p.exists():problems.append([rowno,'source_missing',str(src)]);continue
        cache[src]=json.loads(p.read_text(encoding='utf-8'))
    try:
        d=cache[src]
        if src=='System.json':
            if index=='gameTitle': actual=d['gameTitle']
            else:actual=d['terms']['commands'][int(str(index).split('.')[-1])]
        else:
            cmd=d['events'][int(eid)]['pages'][int(page)]['list'][int(index)]
            expected={'對話':401,'捲動文字':405,'選項':102}
            if cmd['code']!=expected.get(kind):raise ValueError('code mismatch')
            actual=cmd['parameters'][0][int(choice)] if kind=='選項' else cmd['parameters'][0]
        if actual!=original and actual!=target and not (str(src)=='Map002.json' and int(eid)==2 and int(page)==0 and actual==''):
            problems.append([rowno,'source_mismatch',str(actual)[:80],str(original)[:80]])
        if target is not None and str(target).strip():
            # RPG Maker escape variables, colors, icons and pauses need preserved.
            token=re.compile(r'\\(?:[VNPCIG]|[VNPCIG]\[\d+\]|[{}.$|!><^\\])',re.I)
            orig_tokens=token.findall(str(original or ''))
            new_tokens=token.findall(str(target))
            if sorted(orig_tokens)!=sorted(new_tokens): problems.append([rowno,'control_codes',orig_tokens,new_tokens])
            if len(str(target))>80:problems.append([rowno,'long_line',len(str(target))])
            if len(sample)<12 and src=='Map002.json':sample.append([rowno,original,target])
    except Exception as ex:problems.append([rowno,'lookup_error',str(ex)])
print(json.dumps({'sheets':[(s.title,s.max_row,s.max_column) for s in book],'stats':stats,'problem_count':len(problems),'problems':problems[:100],'opening_sample':sample},ensure_ascii=True))
