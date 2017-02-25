local function parse(pl)
    local pl = string.match(pl, "(.+) HTTP/")
    local meth, pl = pl:match("(%w+) (.+)")
    local i = pl:find("?")
        if i == nil then
        return meth, pl, {}
    end
    local filen = pl:sub(1, i-1)
    pl = pl:sub(i+1)
    argv = {}; i = 0
    for arg in string.gmatch(pl, "([^&]+)") do
        local nam, val = string.match(arg, "(.*)=(.*)")
        if nam ~= nil then argv[nam] = val end
        i = i + 1
    end
    return meth, filen, argv
end

return function()
    local s = net.createServer(net.TCP, 5)
    s:listen(80, function(c)
        c:on("receive", function(c, payl)
            local method, reqfile, args = parse(payl)
            print(method, reqfile)

            if method ~= "GET" or reqfile ~= "/" then return end
            method, reqfile = nil, nil
            
            if next(args) ~= nil then
                dofile("ws_funcs.lc")(args)
                args = nil
            end
            
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
