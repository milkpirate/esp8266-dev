local function coLd(f)
  tmr.unregister(6)
  coBdy = nil
  coBdy = coroutine.create(f)
  if dly < 10 then dly = 10 end
  tmr.alarm(6, dly, tmr.ALARM_AUTO, function()
    local stat, err = coroutine.resume(coBdy)
    if err ~= nil then print(err) end
    if stat == "dead" then
        tmr.unregister(6);
        coBdy = nil
    end
  end)
end

local function swpClr(rgb)
  coLd(function()
    for i=0,pxC do
      wsS = wsS:sub(1,3*i)..rgb..wsS:sub(3*i+4)
      ws2812.writergb(wsP,wsS)
      coroutine.yield()
    end
    tmr.unregister(6)
    coBdy = nil
  end)
end

local function rbCyl()
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
            ws2812.writergb(wsP,wsS)
            i = i+2
            coroutine.yield()
        end
    end)
end

local function clrSrt()
  coLd(function()
    local i = 0
    while true do
      local p = i%256
      if p < 85 then p = string.char(255-3*p,3*p,0)
      elseif p < 170 then p = p-85; p = string.char(0,255-3*p,3*p)
      else p = p-170; p = string.char(3*p,0,255-3*p) end
      wsS = p:rep(pxC)
      ws2812.writergb(wsP,wsS)
      i = i+1
      coroutine.yield()
    end
    tmr.unregister(6)
    coBdy = nil
  end)
end

return function (args)
    -- switch light
    if args["lit"] ~= nil then
        tmr.stop(6)
        gpio.write(litP, 0)
        tmr.alarm(5, 100, tmr.ALARM_SINGLE, function()
            gpio.write(litP, 1)
            tmr.start(6)
        end)
        
    -- turn everything off
    elseif args["tot"] ~= nil then
        tmr.unregister(6)
        coBdy = nil
        wsS = string.char(0):rep(pxC*3)
        ws2812.writergb(wsP,wsS)
        gpio.write(litP, 0)

     -- plain color
    elseif args["clr"] ~= nil then
        local clr=args["clr"]:gsub("..", function(c)
            return string.char(tonumber(c, 16))
        end)
        dly = 50
        swpClr(clr)
        --sS = clr:rep(pxC*3)
        --ws2812.writergb(wsP,wsS)
    
    -- change brightness
    elseif args["brt"] ~= nil then
        local b = tonumber(args["brt"])
        if b ~= nil then
            if coBdy ~= nil then return end
            b = b%101
            local wsL = wsS:gsub('.', function(c)
                return string.char((string.byte(c)*b)/100)
            end)
            ws2812.writergb(wsP,wsL)
        end
    
    -- rainbow!!
    elseif args["rbdly"] ~= nil then
        dly = tonumber(args["rbdly"])
        if dly ~= nil then rbCyl() end
        
    -- change color over time
    elseif args["ccotdly"] ~= nil then
        dly = tonumber(args["ccotdly"])
        if dly ~= nil then clrSrt() end
    end

    collectgarbage()
end
