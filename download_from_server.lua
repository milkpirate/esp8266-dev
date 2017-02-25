srv_url="http://192.168.177.2/esp-storage/"..node.chipid().."/"

function get_files()
    http.get(srv_url, nil, function(code, data)
        if code ~= 200 then print("http fail: ", code); return; end
        code, data = pcall(function() return cjson.decode(data) end)
        if not code then print("dcode fail") end
        tmr.alarm(0, 10, tmr.ALARM_SINGLE, function() 
            for idx,name in pairs(data) do
                http.get(srv_url .. name, nil, function(code, content)
                   if code ~= 200 then print("http fail: ", code); return; end
                   file.open(name, "w+")
                   file.write(content)
                   file.close()
                end)
            end
        end)
    end)
end

get_files(dl_files)