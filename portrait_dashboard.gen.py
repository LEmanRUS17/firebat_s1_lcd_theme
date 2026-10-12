import json
W=[]; nid=[0]
def add(group,name,rect,**kw):
    nid[0]+=1
    w={"id":nid[0],"group":group,"name":name}
    w.update(kw); w["rect"]=dict(zip(("x","y","width","height"),rect)); w.setdefault("refresh",0); w["debug_frame"]=False
    W.append(w)
def text(g,val,fmt,font,color,align,rect,refresh,sensor=True):
    add(g,"text",rect,sensor=sensor,value=val,format=fmt,font=font,color=color,align=align,refresh=refresh)
text(1,"clock","{0}","bold 26px Arial","#ffffff","center",(0,4,170,28),5000)
text(1,"calendar","{5}, {7} {2}","13px Arial","#878787","center",(0,32,170,16),30000)
rows=[("cpu_usage","{0}","chip","#00e600","CPU","{0}%",1000),
      ("cpu_temp","{0}","thermometer","#ff6600","Температура","{0}°C",1000),
      ("memory","{2}","memory","#3399ff","RAM {14}","{2}%",2000)]
y=56
for i,(s,dfmt,icon,col,label,val,ref) in enumerate(rows):
    g=2+i
    add(g,"doughnut_chart",(6,y,60,60),sensor=True,value=s,format=dfmt,used=col,free="#333333",refresh=ref)
    add(g,"iconify",(21,y+15,30,30),sensor=False,value=icon,iconSet="mdi",color="#ffffff",refresh=0)
    text(g,s,label,"13px Arial","#aaaaaa","left",(72,y+10,96,17),ref*2,sensor=True)
    text(g,s,val,"bold 22px Arial",col,"left",(72,y+28,96,26),ref)
    y+=66
# y = 254
add(5,"iconify",(6,y+2,20,20),sensor=False,value="harddisk",iconSet="mdi",color="#cccccc",refresh=0)
text(5,"space_root","Диск: {4}%","14px Arial","#cccccc","left",(32,y+3,136,19),10000)
y+=30
add(6,"iconify",(6,y+2,20,20),sensor=False,value="lan",iconSet="mdi",color="#cccccc",refresh=0)
text(6,"network_vmbr0","{0}: {17}","14px Arial","#cccccc","left",(32,y+3,136,19),10000)
theme={"orientation":"portrait","refresh":"redraw","screens":[{"id":1,"name":"System","background":"#000000","duration":15000,
 "led_config":{"theme":1,"intensity":1,"speed":1},"widgets":W,"enabled":True}]}
print(json.dumps(theme,ensure_ascii=False,indent=3))
