return function(req)
    if req.conf == "settings" then
        req.conf = nil
        for n,v in pairs(req) do settings[n] = req[n] end  
              
        file.open("settings", "w+")
        file.writeline(cjson.encode(settings))
        file.close()
    elseif req.conf == "wifi_conf" then
        file.open("wifi_conf", "r")
        local wifi_conf = cjson.encode(file.readline())
        file.close()
        
        wifi_conf.sta_conf.ssid = req["ssid"]
        wifi_conf.sta_conf.pwd  = req["pwd"]
        
        file.open("wifi_conf", "w+")
        file.writeline(cjson.encode(wifi_conf))
        file.close()
        -- delay
        node.restart()
        end
    end
end