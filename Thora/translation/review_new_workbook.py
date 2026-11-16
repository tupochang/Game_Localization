import collections,json,openpyxl,pathlib,re
root=pathlib.Path(__file__).resolve().parents[1]
old=openpyxl.load_workbook(root/'translation/托拉的勇者_劇情翻譯.xlsx',read_only=True,data_only=True)
new=openpyxl.load_workbook(root/'translation/托拉的勇者_劇情翻譯_NEW.xlsx',read_only=True,data_only=True)
summary={};issues=[];examples=[]
control=re.compile(r'\\(?:[VNPCIG]\[\d+\]|[VNPCIG]|[{}.$|!><^\\])|%\d+',re.I)
for si,sheet in enumerate(new):
    rows=list(sheet.values);prev=list(old.worksheets[si].values)
    changes=[];statuses=collections.Counter()
    seen=set()
    for n,row in enumerate(rows[1:],2):
        target_col=9 if si==0 else 5
        source_col=8 if si==0 else 4
        current=row[target_col] if len(row)>target_col else None
        source=row[source_col] if len(row)>source_col else None
        status=row[10 if si==0 else 6] if len(row)>(10 if si==0 else 6) else None
        statuses[str(status)]+=1
        key=(row[0],row[2],row[4],row[5],row[7]) if si==0 else (row[1],row[7])
        if key in seen:issues.append([sheet.title,n,'duplicate_key',key])
        seen.add(key)
        if current is None or not str(current).strip():issues.append([sheet.title,n,'blank_translation',str(source)[:60]])
        if isinstance(current,str) and isinstance(source,str):
            a=sorted(control.findall(source));b=sorted(control.findall(current))
            if a!=b:issues.append([sheet.title,n,'control_code_change',a,b])
            if len(current)>90:issues.append([sheet.title,n,'long_text',len(current)])
        if n-1<len(prev) and current!=prev[n-1][target_col]:
            changes.append([n,source,prev[n-1][target_col],current])
            if len(examples)<25:examples.append([sheet.title,n,source,current])
    summary[sheet.title]={'rows':len(rows)-1,'changes':len(changes),'statuses':statuses,'change_examples':changes[:20]}
print(json.dumps({'summary':summary,'issue_count':len(issues),'issues':issues[:100],'examples':examples},ensure_ascii=True))
