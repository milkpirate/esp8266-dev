local a={txt="text/plain",htm="text/html",pht="text/html",lua="text/html",html="text/html"}
function executeCode(b,c)local d=print;local e=function(...)for f,g in ipairs(arg)do b:send(tostring(g))end
 end;print=e;local h,i=loadstring(c)if h~=nil then local j,i=pcall(assert(h))if j==false 
 then print("Runtime error: ",i)end else b:send("Syntax error: "..i)end;print=d;e=nil;d=nil;h=nil end;
 function sendFile(b,k,l)if file.open(k,"r")then local m=string.match(k,"%.([%a%d]+)$")
 b:send(responseHeader("200 OK",a[m or"txt"]))local n=""local o=false;local p="get = { \[\"file\"\] = \""..k.."\""
 if l~=nil and l~=""then l=l.."&"for f in string.gmatch(l,"[^&]+")do 
 local _,_,q,r=string.find(f,"(.+)=(.+)")p=p..", \[\""..q.."\"\]=\""..r.."\" "end end;p=p.."} \n"repeat 
 local line=file.readline()if line then if line:find("<%?lua(.+)%?>")then n=p.." "..getCode(line,"<%?lua(.+)%?>")
 executeCode(b,n)o=false elseif line:find("<%?lua")then n=p.." "..getCode(line,"<%?lua(.+)")o=true 
 elseif line:find("%?>")then n=n.." "..getCode(line,"(.+)%?>")executeCode(b,n)o=false elseif o then n=n.." "..line 
 else b:send(line)end end until not line;file.close()else b:send(responseHeader("404 Not Found","text/html"))
 b:send("Page not found")end end;function getCode(s,t)local _,_,u=string.find(s,t)if u==nil then u=""end;return u end;
 function responseHeader(c,v)return"HTTP/1.1 "..c.."\r\nConnection: close\r\nServer: luaweb\r\nContent-Type: "..v.."\r\n\r\n"end;
 local w=net.createServer(net.TCP)w:listen(80,function(b)b:on("receive",
 function(b,x)_,_,method,req=string.find(x,"([A-Z]+) (.+) HTTP/(%d).(%d)")_,_,fname,l=string.find(req,"/(.+%.[a-z]+)%??(.*)")
 print(fname)print(l)if fname~=nil then sendFile(b,fname,l)else sendFile(b,"index.html","")end end)
 b:on("sent",function(b)b:close()end)end)