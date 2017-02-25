function coLd(f)    
    tmr.stop(wsT)
    coBdy = nil
    coBdy = coroutine.create(f)
    if dly < 10 then dly = 10 end
    tmr.alarm(wsT, 1, 1, function()
        if (tmr.now()-ltC)/1000 > dly then  -- dly = [ms]
            if coroutine.resume(coBdy) then
                ltC = tmr.now()
            else
                tmr.stop(wsT)
                coBdy = nil
            end
        end
    end)
end

function swpClr(rgb)
    coLd(function()
        for i=0,pxC do
            wsS = wsS:sub(1,3*i)..rgb..wsS:sub(3*i+4)
            ws2812.writergb(wsP,wsS)
            coroutine.yield()
        end
        tmr.stop(wsT)
        coBdy = nil
    end)
end

function chBrt(brt)
    if coBdy ~= nil then return end
    brt = brt%101 -- saturation
    local wsL = wsS:gsub(".", function(p)
        return string.char((string.byte(p)*brt)/100)
    end)
    ws2812.writergb(wsP,wsL)
end

function rbCyl()
    coLd(function()
        i = 0
        while true do
            for p=0,pxC do
                local x = (p*255/pxC+i)%256
                if x > 170 then
                    x = x-170
                    x = string.char(3*x,0,255-3*x)
                elseif x > 85 then
                    x = x-85
                    x = string.char(0,255-3*x,3*x)
                else
                    x = string.char(255-3*x,3*x,0)
                end
                wsS = wsS:sub(1,3*p)..x..wsS:sub(3*p+4) 
            end
            ws2812.writergb(wsP,wsS)
            i = i+1
            coroutine.yield()
        end
    end)
end

function clrSrt()
    coLd(function()
        i = 0
        while true do
            local x = i%256
            if x > 170 then
                x = x-170
                x = string.char(3*x,0,255-3*x)
            elseif x > 85 then
                x = x-85
                x = string.char(0,255-3*x,3*x)
            else
                x = string.char(255-3*x,3*x,0)
            end
            wsS = x:rep(pxC)
            ws2812.writergb(wsP,wsS)
            i = i+1
            coroutine.yield()
        end
    end)
end