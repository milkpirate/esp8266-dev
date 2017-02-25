function coLd(f)
  tmr.unregister(6)
  coBdy = coroutine.create(f)
  if dly < 10 then dly = 10 end
  tmr.alarm(6, dly, tmr.ALARM_AUTO, function()
    if not coroutine.resume(coBdy) then
        tmr.unregister(6);
        coBdy = nil
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
    tmr.unregister(6)
    coBdy = nil
  end)
end

function rbCyl()
  coLd(function()
    local i = 0
    while true do
      for p=0,pxC do
        p = ((p*255)/pxC+1)%256
        if p < 85 then p = string.char(255-3*p,3*p,0)
        elseif p < 170 then p = p-85; p = string.char(0,255-3*p,3*p)
        else p = p-170; p = string.char(3*p,0,255-3*p) end
        wsS = wsS:sub(1,3*i)..p..wsS:sub(3*i+4)
      end
      ws2812.writergb(wsP,wsS)
      i = i+1
      coroutine.yield()
    end
    tmr.unregister(6)
    coBdy = nil
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
      ws2812.writergb(wsP,wsS)
      i = i+1
      coroutine.yield()
    end
    tmr.unregister(6)
    coBdy = nil
  end)
end

function chBrt(b)
  if coBdy ~= nil then return end
  b = b%101
  local wsL = wsS:gsub('.', function(c)
    return string.char((string.byte(c)*b)/100)
  end)
  ws2812.writergb(wsP,wsL)
end
