import json,urllib.request,time,subprocess,sys,os
email=sys.argv[1]; pw=sys.argv[2]
ua=open("/work/ev/ua.txt").read().strip()
os.system("rm -rf /tmp/cdp1")
p=subprocess.Popen(["/usr/bin/chromium","--headless=new","--no-sandbox","--disable-gpu","--disable-dev-shm-usage","--remote-debugging-port=9222","--user-data-dir=/tmp/cdp1","--proxy-server=http://127.0.0.1:3128","--user-agent="+ua,"about:blank"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
ws_url=None
for i in range(40):
    try:
        j=json.load(urllib.request.urlopen("http://127.0.0.1:9222/json",timeout=2))
        for t in j:
            if t.get("type")=="page": ws_url=t["webSocketDebuggerUrl"]; break
        if ws_url: break
    except: pass
    time.sleep(0.5)
if not ws_url:
    print("NO_CDP"); p.terminate(); sys.exit(1)
import websocket
w=websocket.create_connection(ws_url,timeout=30)
n=[0]
def cmd(m,pr=None):
    n[0]+=1; i=n[0]
    w.send(json.dumps({"id":i,"method":m,"params":pr or {}}))
    while True:
        r=json.loads(w.recv())
        if r.get("id")==i: return r
def ev(js):
    r=cmd("Runtime.evaluate",{"expression":js,"returnByValue":True,"awaitPromise":True})
    return r.get("result",{}).get("result",{}).get("value")
cmd("Page.enable")
cmd("Page.navigate",{"url":"https://dashboard.stripe.com/login"})
for i in range(60):
    if ev("document.querySelector(`input[name=email]`)||document.querySelector(`input[type=password]`)"): break
    time.sleep(1)
print("READY",i)
print("URL1",ev("location.href"))
print("TXT1",str(ev("document.body.innerText.slice(0,200)")))
setjs="""(function(){var s=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,"value").set;var e=document.querySelector("input[name=email]")||document.querySelector("input[type=email]");var q=document.querySelector("input[name=password]")||document.querySelector("input[type=password]");if(e){s.call(e,"%s");e.dispatchEvent(new Event("input",{bubbles:true}))}if(q){s.call(q,"%s");q.dispatchEvent(new Event("input",{bubbles:true}))}return [!!e,!!q]})()"""%(email,pw)
print("FILL",ev(setjs))
time.sleep(1)
print("CLICK",ev("(function(){var b=document.querySelector(\"button[type=submit]\")||document.querySelector(\"button\");if(b){b.click();return b.innerText}return \"NOBTN\"})()"))
time.sleep(10)
t2=str(ev("document.body.innerText"))
print("URL2",ev("location.href"))
print("TXT2",t2[:400])
if ("パスキー" in t2) or ("passkey" in t2.lower()):
    print("PASSKEY")
    print("PK",ev("(function(){var bs=[].slice.call(document.querySelectorAll(\"button,a\"));for(var i=0;i<bs.length;i++){if(/パスワード/.test(bs[i].innerText)){bs[i].click();return bs[i].innerText}}return \"NOPK\"})()"))
    time.sleep(3)
    print("URL3",ev("location.href"))
    print("TXT3",str(ev("document.body.innerText.slice(0,300)")))
p.terminate()
