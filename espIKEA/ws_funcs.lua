function coLd(f)
    tmr.unregister(6)
    local coBdy = coroutine.create(f)
    if dly < 10 then dly = 10 end
    tmr.alarm(6, dly, tmr.ALARM_AUTO, function()
        if not coroutine.resume(coBdy) then tmr.unregister(6); end
    end)
end

function swpClr(rgb)
    coLd(function()
        for i=0,pxC do
            wsS = wsS:sub(1,3*i)..rgb..wsS:sub(3*i+4)
            ws2812.write(wsS)
            coroutine.yield()
        end
        tmr.unregister(6)
        coBdy = nil
    end)
end

function rbCyl()
    coLd(function()
        local i = 0
        while true do
            wsS = ""
            for j=0,pxC-1 do
                local p = ((255*j)/(pxC-1)+i)%256
                if p < 85 then p = string.char(255-3*p,3*p,0)
                elseif p < 170 then p = p-85; p = string.char(0,255-3*p,3*p)
                else p = p-170; p = string.char(3*p,0,255-3*p) end
                wsS = wsS..p
            end
            ws2812.write(wsS)
            i = i+2
            coroutine.yield()
        end
    end)
end

function clrSrt()
    coLd(function()
        local i = 0
        while true do
            local p = i%256
            if p < 85 then p = string.char(255-3*p,3*p,0)
            elseif p < 170 then p = p-85; p = string.char(0,255-3*p,3*p)
            else p = p-170; p = string.char(3*p,0,255-3*p) end
            wsS = p:rep(pxC)
            ws2812.write(wsS)
            i = i+1
            coroutine.yield()
        end
    end)
end

return function (name, value)
    -- switch light
    if name == "lit" then
        gpio.write(litP, 0)
        tmr.delay(100)
        gpio.write(litP, 1)
        
    -- turn everything off
    elseif name == "tot" then
        tmr.unregister(6)
        wsS = string.char(0):rep(pxC*3)
        ws2812.write(wsS)

        gpio.mode(4, gpio.INPUT)
        local litStt = gpio.read(4)
        gpio.mode(4, gpio.OUTPUT, gpio.FLOAT)
        ws2812.init()

        -- if light==1 then turn it off
        if litStt == 1 then
            gpio.write(litP, 0) 
            tmr.delay(100)
            gpio.write(litP, 1)
        end
        -- if light==0 then leave it off

     -- plain color
    elseif name == "clr" then
        dly = 50      
        value = string.char(tonumber(value:sub(3,4),16),tonumber(value:sub(1,2),16),tonumber(value:sub(5,6),16))
        swpClr(value)
        --sS = clr:rep(pxC*3)
        --ws2812.write(wsS)
    
    -- change brightness
    elseif name == "brt" and tmr.state(6) == nil then
        value = tonumber(value)
        if value ~= nil then
            if coBdy ~= nil then return end
            value = value%101
            local wsL = wsS:gsub('.', function(c)
                return string.char((string.byte(c)*value)/100)
            end)
            ws2812.write(wsL)
        end
    
    -- rainbow!!
    elseif name == "rbdly" then
        dly = tonumber(value)
        if dly ~= nil then rbCyl() end
        
    -- change color over time
    elseif name == "ccotdly" then
        dly = tonumber(value)
        if dly ~= nil then clrSrt() end
    end

    collectgarbage()
end