local ext={txt="text/plain",htm="text/html",pht="text/html",gif="image/gif",jpg="image/jpeg",png="image/png",lua="text/html",html="text/html"}

local function header(code, type)
	return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: eLua-miniweb\r\nContent-Type: " .. type .. "\r\n\r\n"
end

local function static(req)
	local block
	repeat
		block = file.read(1460)
		req.send(block)
	until not block
end

srv=net.createServer(net.TCP, 180) 
srv:listen(80,function(conn) 
	local req = {}
	local size = 0
	local co
	local clen = 0
	local datalen = 0
	req.send = function(s)
		size = size + #s
		print(size, node.heap())
		while size >= 1460 do
			size = size - 1460
			conn:send(s:sub(1, -size - 1))
			s = s:sub(-size)
			print("yielding", size)
			coroutine.yield()
		end
		if size > 0 then conn:send(s) end
	end
	conn:on("sent",function
		if (not coroutine.resume(co)) or coroutine.status(co) == "dead" and size == 0 and clen == datalen then
			conn:close()
			file.close()
			conn = nil
			return
		end
	end)
	conn:on("receive",function(conn,request)
		print("receive", req.method, #request)
		if req.method ~= nil then
			print("more data received", #request)
			datalen = datalen + #request
			if req.onData then req.onData(request, datalen == clen) end
			return
		end
		req.method, req.path, req.qs, req.headers, req.body =
			request:match("([A-Z]+) /([^ ?]*)(%??[^ ]*) HTTP/%d.%d\r\n(.-)\r\n\r\n(.*)$")
		datalen = #req.body
		req.ext = req.path:match(".*%.(.*)")
		if req.qs then for k,v in req.qs:gmatch("[?&]([^=]+)=([^&]+)") do req[k] = v end end
		if req.headers then for k,v in req.headers:gmatch("([^\r\n:]+): ?([^\r]+)") do req[k] = v end end
		clen = tonumber(req["Content-Length"])
		print(req.method, req.path, req.qs, req.headers, node.heap())
		if not file.open(req.path) then
			conn:send(header("404 NOT FOUND", "text/plain"))
			conn:close()
			conn = nil
			return
		end
		conn:send(header("200 OK", ext[req.ext]))
		req.fn = static
		if req.ext == "pht" or req.ext == "lua" then
			req.fn, error = loadfile(req.path:sub(1,-4).."lc")
			if not req.fn then req.fn = function(req) req.send(error) end end
		end
		co = coroutine.create(req.fn)
		coroutine.resume(co, req)
	end)
end)
