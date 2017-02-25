local extmap = {
  txt = "text/plain",
  htm = "text/html",
  pht = "text/html",
  --gif = "image/gif", one day little esp ... one day.
  --jpg = "imge/jpeg",
  --png = "image/png",
  lua = "text/html",
  html = "text/html"
}

local requestToConsole = true;

local reqTypes = {
	GET = true,
	POST = true
}

local tags = '<%?lua(.-)%?>';

local function docode(thecode)
  local strbuf = {};
  local oldprint, newprint =  print, function(...)
    local total, idx = select('#', ...)
    for idx = 1, total do
      strbuf[#strbuf + 1] = tostring(select(idx, ...)) .. (idx == total and '\n' or '\t');
    end
  end
  print = newprint;
  local f = loadstring(thecode);
  local status, error = pcall(f);
  if status == false then
		print (">>Error: " .. error .. "<<");
  end
  print = oldprint;
  newprint = nil;
  oldprint = nil;
  status = nil;
  error = nil;
  return table.concat(strbuf);
end

sendFileContents = function(conn, type)
	repeat 
		local line=file.readline() 
		if line then 
			 if type == "pht" then
				conn:send(line:gsub(tags, docode));
			 else
				conn:send(line);
			 end
		end 
	until not line 
	file.close();
end

responseHeader = function(code, type)
	return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: eLua-miniweb\r\nContent-Type: " .. type .. "\r\n\r\n"; 
end

httpserver = function ()
 srv=net.createServer(net.TCP) 
    srv:listen(80,function(conn) 
      conn:on("receive",function(conn,request) 

		local hb = node.heap();

		reqdata = {};

		_, _, method, req, major, minor = string.find(request, "([A-Z]+) (.+) HTTP/(%d).(%d)");

		if reqTypes[method] then


			local fname = "";
			if req:find("%?") then
				local rest
				_, _, fname, rest = req:find("(.*)%?(.*)");
				--rest = rest .. "&";
				--for crtpair in rest:gmatch("[^&]+") do
					--local _, __, k, v = crtpair:find("(.*)=(.*)");
					---- replace all "%xx" characters with their actual value
					--v = v:gsub("(%%%x%x)", function(s) return string.char(tonumber(s:sub(2, -1), 16)) end);
					--reqdata[k] = v;
				--end
			else
				fname = req;
			end

			fname = ( fname == "/" ) and "index.pht" or fname:sub(2, -1);

			s, e = fname:find("%.[%a%d]+$");
			local ftype = fname:sub(s+1, e):lower();
			ftype = (#ftype > 0 and ftype) or "txt";

			if file.open(fname, "r") then
				conn:send(responseHeader("200 OK",extmap[ftype or "txt"]));
				sendFileContents(conn,ftype);
			else
				conn:send(responseHeader("404 Not Found","text/html"));
				conn:send("Page not found");
			end

			if requestToConsole then
				print(method .. ":" .. fname .. ", MemUsage:" .. (hb-node.heap()) .. " (" .. node.heap() .. ")");
			end

			fname, ftype ,s, e = nil;

		else
			print("Invaild Request");
			conn:send(responseHeader("400 Bad Request","text/html"));
			conn:send("400 Invaild Request");
		end

		_, method, req, major, minor, request, reqdata, hb = nil, nil, nil, nil, nil, nil, nil, nil;


      end) 
		conn:on("sent",function(conn)
			conn:close();
			conn = nil;	
		end)
    end)
end

httpserver()