return function (connection, req, args)
    print(node.heap())
    -- switch light
    if args["lit"] ~= nil then
        if args["lit"] == "1" then
            print("on ", node.heap())
            gpio.write(litP, 1)
        else
            print("off ", node.heap())
            gpio.write(litP, 0)
            print("off set ", node.heap())
        end
    
    -- turn everything off
    elseif args["tot"] ~= nil then
        print(node.heap())
        tmr.stop(wsT)
        coBdy = nil
        wsS=string.char(0):rep(pxC*3)
        ws2812.writergb(wsP,wsS)
        gpio.write(litP, 0)
    
    -- plain color
    elseif args["clr"] ~= nil then
        local clr=args["clr"]:gsub("..", function(c)
            return string.char(tonumber(c, 16))
        end)
        dly = 25
        swpClr(clr)
        clr = nil
        
    -- change brightness
    elseif args["brt"] ~= nil then
        print(args["brt"], tonumber(args["brt"]))
        dly = tonumber(args["brt"])
        if dly ~= nil then chBrt() end   

    -- change color over time
    elseif args["rbdly"] ~= nil then
        dly = tonumber(args["rbdly"])
        if dly ~= nil then rbCyl() end
        
    -- change color over time
    elseif args["ccotdly"] ~= nil then
        dly = tonumber(args["ccotdly"])
        if dly ~= nil then clrSrt() end
    end

    local litSt = gpio.read(litP)
  
    if file.open("http/remote.html", "r") then
        while true do 
            local line=file.readline()
            if line == nil then
                file.close()
                break
            end
            line = line:gsub("LUA_LGH_STT",(litSt+1)%2)
            line = line:gsub("LUA_LGH_BTN","&#12830"..(6+litSt)..";")
            connection:send(line)
        end
    else
        connection:send("<html><head><title>404 - Not Found</title></head><body><h1>404 - Not Found</h1></body></html>")
    end

    -- clean up
    dly = 10
    litSt = nil
    collectgarbage()
end
