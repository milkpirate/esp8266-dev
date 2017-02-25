settings = {}
settings.temp_corr      = 16.0                  -- [°C]
settings.lit_pro_cm     = 38.73                 -- [l/cm]
settings.tank_hi        = 150.0                 -- [cm]
settings.sensor_offset  = 0.0                   -- [cm]
settings.tank_vol       = 5000                  -- [l]
settings.update_intv    = 12                    -- [hrs]
settings.avg_num        = 16                    -- [#]
settings.channelid      = <ch_id>                -- [#]
settings.api_key        = "<api_key>"    -- thingspeak api key
settings.fuellung       = 2568.5                -- [l]

if srv ~= nil then srv:close() end
srv = net.createServer(net.TCP, 10)

srv:listen(80, function(conn)
    conn:on("receive", function(conn, pl)
        pl = string.match(pl, "(.+) HTTP/")
        
        pl = pl:match("%w+ (.+)")
        if pl == "/favicon.ico" then
            conn:send("HTTP/1.1 404 Not Found")
            return
        end
        pl = pl:sub(5,#pl-3):gsub('%%22','"')
        
        local ok = pcall(function() pl = cjson.decode('{'..pl..'}') end)
        if ok and next(pl) then
            for n,v in pairs(pl) do print(n,v) end
            --dofile("write_settings")(pl)
        end
        pl = nil

        conn:on("sent", nextChunk)
        
        local nextChunk = coroutine.wrap(function(c)
            local idx = 0
            
            file.open("wifi_conf")
            local wifi_conf = file.readline()
            file.close()
            
            file.open("index.html")
            local fend = file.seek("end")
            file.close()
            
            while idx < fend do
                file.open("index.html")
                file.seek("set", idx)
                local str = file.read(512)
                file.close()

                if idx == 0 then
                    str = str:gsub('LUA_set', cjson.encode(settings))
                    str = str:gsub('LUA_wif', wifi_conf:match("^%s*(.-)%s*$"))
                    wifi_conf = nil
                end
                              
                idx = idx+512
                c:send(str)
                coroutine.yield()
            end
            c:close()
        end)
        
        nextChunk(conn)
    end)
    print("HTTP server started.")
end)
