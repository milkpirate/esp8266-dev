local ext={txt="text/plain",htm="text/html",pht="text/html",gif="image/gif",jpg="image/jpeg",png="image/png",lua="text/html",html="text/html"}

header = function(code, type)
	return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: eLua-miniweb\r\nContent-Type: " .. type .. "\r\n\r\n"
end

function static(req)
	local block
	repeat
		block = file.read(1460)
		req.send(block)
	until not block
end

function pht(req)
	local next = -1
	local block
	local html = true
	local f, error = load(function()
		if next == -1 then
			next = "<?"
			return "local req = ...\n"
		end
		block = file.read(next:sub(-1))
		if not block then return nil end
		local swap = block:sub(-2) == next
		if swap then block = block:sub(1, -3) end
		if html then
			block = "req.send([["..block.."]])"
		else
			block = block:gsub("^=(.*)", "req.send(%1)")
		end
		if swap then
			html = not html
			next = (html and "<?" or "?>")
		end
		return block
	end)
	if not f then
		req.send("Error parsing pht file: "..error)
	else
		f(req)
	end
end

srv=net.createServer(net.TCP, 180) 
srv:listen(80,function(conn) 
	local req = {}
	local size = 0
	local co
	req.send = function(s)
		size = size + #s
		while size >= 1460 do
			size = size - 1460
			conn:send(s:sub(1, -size - 1))
			s = s:sub(-size)
			coroutine.yield()
		end
		if size > 0 then conn:send(s) end
	end
	conn:on("receive",function(conn,request)
		req.method, req.file, req.qs, req.headers, req.body =
			request:match("([A-Z]+) /([^ ?]*)(%??[^ ]*) HTTP/%d.%d\r\n(.*)\r\n\r\n(.*)")
		req.ext = req.file:match(".*%.(.*)")
		if req.qs then for k,v in req.qs:gmatch("[?&]([^=]+)=([^&]+)") do req[k] = v end end
		if req.headers then for k,v in req.headers:gmatch("([^:]+): ?([^\r]+)") do req[k] = v end end
		if not file.open(req.file) then
			conn:send(header("404 NOT FOUND", "text/plain"))
			conn:close()
			req = nil
			return
		end
		conn:send(header("200 OK", ext[req.ext]))
		req.fn = static
		if req.ext == "lua" then
			req.fn, error = loadfile(req.file)
			if not req.fn then req.fn = function(req) req.send(error) end end
		elseif req.ext == "pht" then
			req.fn = pht
		end
		co = coroutine.create(req.fn)
		coroutine.resume(co, req)
	end)
	conn:on("sent",function()
		if not coroutine.resume(co) or coroutine.status(co) == "dead" and size == 0 then
			conn:close()
			file.close()
			conn = nil
			return
		end
	end)
end)
