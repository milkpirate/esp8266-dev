local srv_url="http://192.168.177.21/"..node.chipid().."/"

local function get_files()
    http.get(srv_url, nil, function(code, data)
        if code ~= 200 then print("http fail: ", code); return; end
        code, data = pcall(function() return cjson.decode(data) end)
        if not code then print("dcode fail"); return; end
        tmr.alarm(0, 10, tmr.ALARM_SINGLE, function() 
            dl_files(data)
        end)
    end)
end

local dl_files = coroutine.wrap(function(list)
    for idx,name in pairs(list) do
        http.get(srv_url .. name, nil, function(code, content)
           if code ~= 200 then print("http fail: ", code); return; end
           print("getting file:", name)
           file.open(name, "w+")
           file.write(content)
           file.close()
        end)
        tmr.alarm(0, 200, tmr.ALARM_SINGLE, function() dl_files() end)
        coroutine.yield()        
    end
	if file.open("main.lua","r") then
		file.close()
		print("start main.lua in 1s...")
		tmr.alarm(0, 1000, 0, function() dofile("main.lua") end)
		srv_url, get_files, dl_files = nil, nil, nil
	else
		print("main.lua not found. reboot...")
		spi_write(rbot)
		tmr.alarm(0, 3000, 0, function() node.restart() end)
	end
end)

get_files()