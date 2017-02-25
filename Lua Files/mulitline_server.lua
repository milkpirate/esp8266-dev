---------------
-- connect as station to a Wifi Access Point
-- Use as : connecttoap("yourSSID","yourpassword")
connecttoap = function (ssid,pw)
    if wifi.sta.getip() == "0.0.0.0" then
      wifi.setmode(wifi.STATION)
      wifi.sta.config(ssid,pw)
    end
    print("Connected to " .. ssid .. " as " .. wifi.sta.getip())
end
------------------------------
-- install a webserver
-- Use as : httpserver()
httpserver = function ()
  srv=net.createServer(net.TCP) srv:listen(80,function(conn) 


    conn:on("receive",function(conn,payload) print(payload) 
	s = string.match(payload,".+HTTP")
	if s == nil then conn:send("Bad Reguest")print("Bad Reguest".. payload) conn:on("sent",function(conn) conn:close() end)
	else
    conn:send("HTTP/1.0 200 OK\r\nContent-type: text/html\r\nServer: test123\r\n\n") 
--	conn:send("<html><head><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js\"></script>") 
--	conn:send("<script>$(document).ready(function(){$(\"button\").click(function(){$(\"#div1\").fadeToggle();});});</script>")
	conn:send("</head><body><h1>")
	conn:send("Served from ESP8266-" .. node.chipid() .. "</h1>")
    conn:send("Debug info : ") 
    conn:send("NODE.CHIPID : " .. node.chipid() .. " ") 
    conn:send("NODE.HEAP : " .. node.heap() .. " ") 
    conn:send("GPIO0 : " .. gpio.read(8) .. " ") 
    conn:send("GPIO1 : " .. gpio.read(9) .. " ") 
    conn:send("ADC0  : " .. adc.read(0) .. " ") 
    
    --conn:send("Request : " .. s  .. "<BR>") 
    s = string.match(s,'%a+%.*%a*',4)
    if s==nil
      then  conn:send("Page : " .. "no page specified" .. "<BR>") 
      else  conn:send("Page : " .. s .. " ") 
    end
    if string.match(s, ".html") == ".html" then
      conn:send("Page type : html file<BR>") 
      conn:send("<HR>")
      file.open(s,"r")

      repeat
        local line=file.readline()
        if line then
          -- strip the \n at the end of the line
          line = string.gsub(line,"\n","")
	  if line == "<?lua" then
            -- skip to the 1st Lua line
            line=file.readline() line = string.gsub(line,"\n","")
            
            while line ~= "?>" do
            if line then
              print("Lua-input:"..line)
              linef=loadstring(line)
              ln=linef()
              if ln then
              ln = string.gsub(ln,"\n","")
              print("Lua-output:"..ln)
              conn:send(ln)
            end
          end
              line=file.readline() line = string.gsub(line,"\n","")

            end
            -- read the next line to process
            line=file.readline()
            line = string.gsub(line,"\n","")
          end
          print("Html:"..line) conn:send(line)
        end
      until not line
      file.close()
    end

    if string.match(s, ".lua") == ".lua" then
      conn:send("Page type : lua file<BR>") 
      print("Executing " .. s)
      dofile(s)
    end
    conn:send("<HR>")
    for k,v in pairs(file.list()) do
      print("name:"..k..",size:"..v)
      conn:send("<a href='")
      conn:send(k)
      conn:send("'>")
      conn:send(k)
      conn:send("</a><BR>")
    end
    conn:send("</html></body>") 
    conn:on("sent",function(conn) conn:close() end)
end	
    end)
  end)
  print("httpserver installed. Browse to " .. wifi.sta.getip())
end
---------------
print("Now scanning for valid IP")

tmr.alarm(1000, 1, function()
   if wifi.sta.getip()=="0.0.0.0" then
      print("Waiting for connection to AP")
   else
    print('Now connect to AP, IP: ',wifi.sta.getip())
    httpserver()
    tmr.stop()
   end
end)
