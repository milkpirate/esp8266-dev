local function parse(pl)
    pl = string.match(pl, "(.+) HTTP/")
    local meth, pl = pl:match("(%w+) (.+)")
    local i = pl:find("?")
	if i == nil then return meth, pl, {} end
    local filen = pl:sub(1, i-1)
    pl = pl:sub(i+1)
    pl = pl:gsub("%%22",'"')
    pl = cjson.decode(pl)
    return meth, filen, pl
end

return function()    
    local srv = net.createServer(net.TCP, 10)
    srv:listen(80, function(conn)
        conn:on("receive", function(conn, pl)
            if file.open("index.html") then
				file.close()
			else
                print("index.html not found")
                return
            end
        
            local method, reqfile, args = parse(pl)
            print(node.heap(), method, reqfile)

            if next(args) ~= nil then dofile("write_settings.lc")(args) end

            if method  ~= "GET" 		 then return end
            if reqfile == "/favicon.ico" then return end
			
			local nextChunk = coroutine.wrap(function (c)
				file.open("wifi_conf", "r")
				wifi_conf = cjson.decode(file.read())
				file.close()
				wifi_conf.sta_conf.pwd = nil
			
				file.open("index.html")
				local str = file.read(512)
				str = str:gsub("LUA_wifi_conf",cjson.encode(wifi_conf))
				str = str:gsub("LUA_settings",cjson.encode(settings))
				wifi_conf = nil
				
				while str ~= nil do
					c:send(str)
					str = file.read(512)
					coroutine.yield()
				end
				
				file.close()
				c:close()
				collectgarbage()
			end)

            conn:on("sent", nextChunk)
            nextChunk(conn)
        end)
    end)
    
    local ip = wifi.sta.getip()
    if not ip then ip = wifi.ap.getip() end
    print("httpserver running at http://" .. ip .. ":80")
    print("serving file: index.html")
    collectgarbage()
    return srv
end
