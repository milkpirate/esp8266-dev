local function parse(pl)
    local meth, file, name
    if pl:find("favicon.ico") then return "FAV" end
    pl = string.match(pl, "(.+) HTTP/")
    meth, pl = pl:match("(%w+) (.+)")
    pl = pl:gsub("/","")
    if pl == "" then return meth end
    file, pl = string.match(pl, "(.*)?(.*)")
    if file == nil then return meth end
    name, pl = string.match(pl, "(.*)=(.*)")
    return meth, name, pl
end

return function()
    local s = net.createServer(net.TCP, 5)
    s:listen(80, function(c)
        c:on("receive", function(c, payl)
            local method, name, value = parse(payl)
            print(method, name, value)

            if method ~= "GET" then return end
            method = nil
            
            if name ~= nil then
                dofile("ws_funcs.lc")(name, value)
                if mqtt_status == 0 then
                    local pub_topic = mqtt_topic:gsub("control","status"):gsub("#","")
                    mq:publish(pub_topic..name, value, 1, 0)
                end
            end
            name, value = nil,nil
            
            local nextChunk = coroutine.wrap(function (c)
                local idx = 0
                
                file.open("index.html")
                local fend = file.seek("end")
                file.close("index.html")

                tmr.stop(6)
                gpio.mode(4, gpio.INPUT)
                local litStt = gpio.read(4)
                gpio.mode(4, gpio.OUTPUT, gpio.FLOAT)
                tmr.start(6)
                ws2812.init()
                                
                while idx < fend do
                    file.open("index.html")
                    file.seek("set", idx)
                    local str = file.read(512)
                    file.close()

                    if idx == 0 then
                        str = str:gsub("LUA_LIT", litStt)
                    end
                    
                    idx = idx+512
                    c:send(str)                  
                    coroutine.yield()
                end
                
                c:close()
                collectgarbage()
                print(node.heap())
            end)

            c:on("sent", nextChunk)
            nextChunk(c)
        end)
    end)
    
    local ip = wifi.sta.getip()
    if not ip then ip = wifi.ap.getip() end
    print("httpserver running at http://" .. ip .. ":80")
    print("serving file: index.html")
    collectgarbage()
    return s
end
