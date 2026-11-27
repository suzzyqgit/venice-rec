import sys,re,os,urllib.request
H=sys.argv[1]
os.environ["https_proxy"]="http://nwxgczwm-jp-rotate:8yma8sifzpty@p.webshare.io:80"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
def get(u):
 try:
  return urllib.request.urlopen(urllib.request.Request(u,headers={"User-Agent":UA}),timeout=25).read().decode("utf-8","ignore")
 except:
  return ""
raw=""
for p in ["/","/tokusyo/","/tokushoho/","/company/","/about/","/contact/","/wp-json/wc/store/v1/products?per_page=60"]:
 raw+=get("https://"+H+p)
t=re.sub(r"(?is)<(script|style)[^>]*>.*?</\1>"," ",raw)
t=re.sub(r"\\u([0-9a-fA-F]{4})",lambda m:chr(int(m.group(1),16)),t)
v=re.sub(r"(?s)<[^>]*>"," ",t)
P="あa いi うu えe おo かka きki くku けke こko さsa しshi すsu せse そso たta ちchi つtsu てte とto なna にni ぬnu ねne のno はha ひhi ふfu へhe ほho まma みmi むmu めme もmo やya ゆyu よyo らra りri るru れre ろro わwa をwo んn がga ぎgi ぐgu げge ごgo ざza じji ずzu ぜze ぞzo だda ぢji づzu でde どdo ばba びbi ぶbu べbe ぼbo ぱpa ぴpi ぷpu ぺpe ぽpo"
K={}
for tk in P.split(): K[tk[0]]=tk[1:]
for k in list(K):
 if "\u3041"<=k<="\u3096": K[chr(ord(k)+0x60)]=K[k]
K["ー"]=""
K["っ"]=""
def rom(s):
 o=[]
 for ch in s:
  if ch in K: o.append(K[ch])
  elif ch.isascii() and ch.isalnum(): o.append(ch.lower())
 return "".join(o)
cand=[]
for part in re.split(r"[.\-]",H):
 if len(part)>=4: cand.append(part)
for m in re.findall(r"(?is)<title>(.*?)</title>",t): cand.append(m)
for m in re.findall(r"(?is)<h[12][^>]*>(.*?)</h[12]>",t): cand.append(m)
for m in re.findall(r"\"name\":\"([^\"]{2,40})\"",t): cand.append(m)
for m in re.findall(r"株式会社\s*([^\s<>\"]{2,20})",v): cand.append(m)
for m in re.findall(r"[\u3041-\u309F\u30A1-\u30FF]{3,12}",v): cand.append(m)
J=set("wordpress jquery none true false html https http class style span data type width height color background margin padding display block inline font weight center relative absolute hidden visible content title target blank script link meta head body section header footer article aside button input label select option form action method value name role aria alt rel charset viewport initial scale maximum minimum user scalable stylesheet text css json php jpg jpeg png webp svg gif woff ttf min ver the and for with from this that are was not you all can new get set use has have will our shop store online site home page post info news blog about contact company policy privacy terms cart account login search category tag archive comment feed rss".split())
W=[]
def add(w):
 w=re.sub(r"u([0-9a-fA-F]{4})",lambda m:chr(int(m.group(1),16)),w)
 w=re.sub(r"[^a-z0-9\-_.!]","",w.lower())
 if len(w)<4 or len(w)>20: return
 if not re.search(r"[a-z]",w): return
 if w in J or w in W: return
 W.append(w)
for c in cand:
 c=re.sub(r"\\?u([0-9a-fA-F]{4})",lambda m:chr(int(m.group(1),16)),c)
 r=rom(c)
 for pc in re.split(r"[^a-z0-9]+",r): add(pc)
 if r and " " not in r: add(r)
B=list(W)
for b in B[:60]:
 for s in ["2026","2025","2024","2023","123","1234","1","01","0000","!","admin","-admin","123!"]:
  add(b+s)
for m in re.findall(r"0\d{1,4}-?\d{1,4}-?\d{3,4}",v):
 d=re.sub(r"\D","",m)
 if len(d)>=8: add(d[-8:]); add(d[-4:])
for m in re.findall(r"\b\d{3}-?\d{4}\b",v):
 d=re.sub(r"\D","",m)
 if len(d)==7: add(d)
print("\n".join(W[:300]))
