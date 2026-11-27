#!/usr/bin/env python3
import glob, os
def norm(h): return h.replace("www.","").strip()
hosts={}
for line in open("/work/ev/ver2.txt"):
    p=line.strip().split("|")
    if len(p)>=2: hosts[norm(p[0])]=p[1]
pay={}
for f in glob.glob("/work/ev/gw2*.txt")+glob.glob("/work/ev/gw5*.txt"):
    for line in open(f, errors="ignore"):
        parts=line.strip().split()
        if not parts: continue
        k=norm(parts[0])
        pay[k]=pay.get(k,"")+" "+" ".join(parts[1:]).lower()
for f in glob.glob("/work/ev/gw4_*.txt"):
    k=norm(os.path.basename(f)[4:-4])
    pay[k]=pay.get(k,"")+" "+open(f,errors="ignore").read().lower()
excl=set()
for line in open("/work/ev/led/ledger2.tsv"):
    p=line.split()
    if len(p)>1 and p[0]!="stage": excl.add(norm(p[1]))
for f in glob.glob("/work/ev/out/a_*.log")+glob.glob("/work/ev/out/oc_*.log"):
    b=os.path.basename(f)
    excl.add(norm(b[2:-4] if b.startswith("a_") else b[3:-4]))
for line in open("/work/ev/queue.txt"):
    p=line.split()
    if p: excl.add(norm(p[0]))
def gv(g):
    if not g or g=="?": return 0
    try: return float(".".join(g.split(".")[:2]))
    except: return 0
rows=[]
for h,g in hosts.items():
    if h in excl: continue
    s=0
    if h in pay:
        p=pay[h]
        if "bacs" in p or "bankjp" in p or "postofficebank" in p: pt="bacs"; s+=4
        elif "stripe" in p: pt="stripe"; s+=2
        else: pt="none"; s-=2
    else:
        pt="unknown"
    v=gv(g)
    if v and v<7.0: s+=3
    elif v and v<7.15: s+=2
    rows.append((s,h,g or "?",pt))
rows.sort(reverse=True)
out=["score host generator pay"]
for r in rows: out.append("%d %s %s %s"%r)
open("/work/ev/led/screen.tsv","w").write("\n".join(out)+"\n")
print("\n".join(out[:18]))
