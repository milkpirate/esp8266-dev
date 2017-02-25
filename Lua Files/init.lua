print("-- Heap: ".. node.heap())
print("-- Configuring WIFI")
wifi.setmode(wifi.STATION)
wifi.sta.config("<ssid>", "<pass>")

print("-- Starting lhttpd")
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
	conn:on("receive",function(conn,request)
	
		reqdata = {};
		_, _, _, req = string.find(request, "([A-Z]+) (.+) HTTP/(%d).(%d)");
		request = nil
		
		local fname = "";
		if req:find("%?") then
			local rest
			_, _, fname, rest = req:find("(.*)%?(.*)");
			rest = rest .. "&";
			for crtpair in rest:gmatch("[^&]+") do
				local _, __, k, v = crtpair:find("(.*)=(.*)");
				v = v:gsub("(%%%x%x)", function(s) return string.char(tonumber(s:sub(2, -1), 16)) end);
				reqdata[k] = v;
			end
		else
			fname = req;
		end
		
		fname = (fname == "/") and "index.pht" or fname:sub(2, -1);

		s, e = fname:find("%.[%a%d]+$")
		local ftype = fname:sub(s+1, e):lower()
		s, e = nil
		
		ftype = (#ftype > 0 and ftype) or "txt"

		if file.open(fname, "r") then
			repeat
				local line=file.readline()
				if line then
					line = string.gsub(line,"\n","")
					if line == "<?lua" then
						line=file.readline()
						line = string.gsub(line,"\n","")
						while line ~= "?>" do
							if line then
								linef=loadstring(line)
								ln=linef()
								if ln then
									ln = string.gsub(ln,"\n","")
									print(ln)
									conn:send(ln)
								end
							end
							line=file.readline()
							line = string.gsub(line,"\n","")
						end
						line=file.readline()
						line = string.gsub(line,"\n","")
					end
				end
			until not line
			file.close()
		else
			conn:send("Page not found")
		end
		
		--print(method .. ":" .. fname .. ", MemUsage:" .. (hb-node.heap()) .. " (" .. node.heap() .. ")");
		--for k,v in pairs(reqdata) do
		--print (k,v)
		--end
		
		_, fname, ftype, reqdata, s, e = nil, nil, nil, nil, nil

	end)
	
	conn:on("sent",function(conn) 
		conn:close()
		conn = nil
	end)
end)
print("-- Heap: ".. node.heap())