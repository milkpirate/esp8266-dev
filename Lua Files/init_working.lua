print("-- Configuring WIFI")
wifi.setmode(wifi.STATION)
wifi.sta.config("Charybdis", "X$ZP3GFu9_K$dAy*G,0Sx]-=ymDu?{wL")

local extmap = {
	--txt = "text/plain",
	htm = "text/html",
	pht = "text/html",
	html = "text/html"
}
local function docode(thecode)
	local strbuf = {};
	local oldprint, newprint =  print, function(...)
		local total, idx = select('#', ...)
		for idx = 1, total do
			strbuf[#strbuf + 1] = tostring(select(idx, ...)) .. (idx == total and '\n' or '\t');
		end
	end
	print = newprint;
	newprint = nil;
	local f = loadstring(thecode);
	pcall(f);
	print = oldprint;
	oldprint = nil;
	return table.concat(strbuf);
end

sendFileContents = function(conn, type)
	repeat 
		local line=file.readline() 
		if line then 
			if type == "pht" then
				local tags = '<%?lua(.-)%?>';
				conn:send(line:gsub(tags, docode));
			else
				conn:send(line);
			end
		end 
	until not line 
	file.close();
end

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
			sendFileContents(conn,ftype)
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