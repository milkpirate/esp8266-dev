------------------------------
-- install a webserver
-- Use as : httpserver()
httpserver = function ()
  srv=net.createServer(net.TCP)
  srv:listen(80,function(conn)
  
    conn:on("receive",function(conn,payload) print(payload) 
	s = string.match(payload,".+HTTP")
	
	if s == nil then
		conn:send("Bad Request")
		print("Bad Request".. payload)
		conn:on("sent",function(conn) conn:close() end)
	else
		conn:send("HTTP/1.0 200 OK\r\nContent-type: text/html\r\nServer: test123\r\n\n") 
	--	conn:send("<html><head><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js\"></script>") 
	--	conn:send("<script>$(document).ready(function(){$(\"button\").click(function(){$(\"#div1\").fadeToggle();});});</script>")
		conn:send("</head><body><h1>")
		conn:send("Served from ESP8266-" .. node.chipid() .. "</h1>")
		conn:send("Debug info : ") 
		conn:send("NODE.CHIPID : " .. node.chipid() .. " ") 
		conn:send("NODE.HEAP : " .. node.heap() .. " ")
	--	conn:send("Request : " .. s  .. "<BR>")
	
		s = string.match(s,'%a+%.*%a*',4)
		if s=="HTTP"
		  then  conn:send("Page : " .. "no page specified" .. "<BR>") 
		  else  conn:send("Page : " .. s .. " ") 
		end
		if string.match(s, ".html") == ".html" then
		  conn:send("Page type : html file<BR>") 
		  conn:send("<HR>")
		  file.open(s,"r")
		  lualines = 0
		  repeat
			local line=file.readline()
			if line then
			  -- strip the \n at the end of the line
			  line = string.gsub(line,"\n","")
			  if line == "<?lua" then print("<?lua : lua ON") line=file.readline() lualines=1 end
			  if line == "?>" then print("?> : lua OFF") line=file.readline() lualines=0  end
			  if line ~= nil then print(lualines,line) conn:send(line) end
			end
		  until not line
		  file.close()
		end
		if string.match(s, ".lua") == ".lua" then
		  conn:send("Page type : lua file<BR>") 
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

httpserver()

