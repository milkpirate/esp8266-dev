return function (c,r,a)  
    -- switch light
    if a["lit"] ~= nil then
        if a["lit"] == "1" then gpio.write(litP, 1)
        else gpio.write(litP, 0) end
    
    -- turn everything off
    elseif a["tot"] ~= nil then
        tmr.unregister(6)
        coBdy = nil
        wsS = string.char(0):rep(pxC*3)
        ws2812.writergb(wsP,wsS)
        gpio.write(litP, 0)
        
    -- plain color
    elseif a["clr"] ~= nil then
        clr=a["clr"]:gsub("..", function(c)
            return string.char(tonumber(c, 16))
        end)
        dly=75
        swpClr(clr)
        
    -- change brightness
    elseif a["brt"] ~= nil then
        local b = tonumber(a["brt"])
        if b ~= nil then chBrt(b) end
        
    -- change color over time
    elseif a["rbdly"] ~= nil then
        dly = tonumber(a["rbdly"])
        if dly ~= nil then rbCyl() end
        
    -- change color over time
    elseif a["ccotdly"] ~= nil then
        dly = tonumber(a["ccotdly"])
        if dly ~= nil then clrSrt() end
    end
    
    litSt = gpio.read(litP)
  
    if file.open("http/remote.html", "r") then
        while true do 
            local line=file.readline()
            if line == nil then break end
            line = line:gsub("LUA_LGH_STT",(litSt+1)%2)
            line = line:gsub("LUA_LGH_BTN","&#12830"..(6+litSt)..";")
            c:send(line)
        end
    else
        c:send("<html><head><title>404 - Not Found</title></head><body><h1>404 - Not Found</h1></body></html>")
    end
    file.close()

    b = nil
    collectgarbage()
end