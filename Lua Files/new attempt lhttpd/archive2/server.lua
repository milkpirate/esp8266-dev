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

srv=net.createServer(net.TCP, 180) 
srv:listen(80,function(conn) 
	local req = {}
	local size = 0
	local co
	local more = false
	local moredata = ""
	local good
	local clen = 0
	local datalen = 0
	local checkClose = function()
		print(good, coroutine.status(co), size)
		if not good or coroutine.status(co) == "dead" then
			conn:close()
			file.close()
			conn = nil
			return true
		end
		return false
	end
	local checkMore = function()
		if checkClose() then return end
		print("more", more, #moredata, clen, datalen)
		if not more then
			good, more = coroutine.resume(co)
		elseif moredata then
			good, more = coroutine.resume(co, moredata)
			moredata = ""
		end
		if checkClose() then return end
		print("checking clen", more, clen, datalen)
		if more and clen == datalen then
			good, more = coroutine.resume(co, nil)
		end
		if checkClose() then return end
	end
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
	conn:on("sent",function()
		print("sent", more)
		checkMore()
	end)
	conn:on("receive",function(conn,request)
		print("receive", req.method, #request)
		if req.method ~= nil then
			print("more data received", #request)
			datalen = datalen + #request
			moredata = moredata .. request
			checkMore()
			return
		end
		req.method, req.path, req.qs, req.headers, req.body =
			request:match("([A-Z]+) /([^ ?]*)(%??[^ ]*) HTTP/%d.%d\r\n(.-)\r\n\r\n(.*)$")
		datalen = datalen + #req.body
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
		good, more = coroutine.resume(co, req)
		checkClose()
	end)
end)
