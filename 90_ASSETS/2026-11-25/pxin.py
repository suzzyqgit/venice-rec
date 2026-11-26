import os,socket,threading,base64
px=os.environ["PX"]
cred,hp=px.rsplit("@",1); host,port=hp.split(":")
auth="Basic "+base64.b64encode(cred.encode()).decode()
def pipe(a,b):
    try:
        while True:
            d=a.recv(65536)
            if not d: break
            b.sendall(d)
    except: pass
    try: b.shutdown(socket.SHUT_WR)
    except: pass
def handle(c):
    try:
        buf=b""
        while b"\r\n\r\n" not in buf:
            d=c.recv(65536)
            if not d: return
            buf+=d
        line=buf.split(b"\r\n")[0].decode()
        if not line.startswith("CONNECT"):
            c.sendall(b"HTTP/1.1 405 x\r\n\r\n"); return
        tgt=line.split()[1]
        u=socket.create_connection((host,int(port)),15)
        u.sendall(("CONNECT %s HTTP/1.1\r\nHost: %s\r\nProxy-Authorization: %s\r\n\r\n"%(tgt,tgt,auth)).encode())
        rb=b""
        while b"\r\n\r\n" not in rb:
            d=u.recv(65536)
            if not d: return
            rb+=d
        if b" 200 " not in rb.split(b"\r\n")[0]:
            c.sendall(rb); return
        c.sendall(b"HTTP/1.1 200 Connection established\r\n\r\n")
        threading.Thread(target=pipe,args=(c,u),daemon=True).start()
        pipe(u,c)
    except: pass
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1); s.bind(("127.0.0.1",3128)); s.listen(50)
while True:
    c,_=s.accept(); threading.Thread(target=handle,args=(c,),daemon=True).start()
