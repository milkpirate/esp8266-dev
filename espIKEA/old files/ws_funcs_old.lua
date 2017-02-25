pixels      = 2
wsPin       = 2
wsString    = string.char(0):rep(pixels*3)

pxlTmrSlot = 6
lastCall = tmr.now()

function setPixelColor(i, r, g, b)
     wsString = wsString:sub(1,3*i)..string.char(r,g,b)..wsString:sub(3*i+4)
end

function adjustBrigh(bright)
	bright = bright%100
	wsString = wsString:gsub(".", function(p)
		return string.char(string.byte(p)*bright/100)
	end)
end

function printPixels(delay)
    if (tmr.now()-lastCall)/1000 > delay then -- delay = [ms]
        if coroutine.resume(printPixelBody) == false then
            printPixelBody = nil
            tmr.stop(pxlTmrSlot)
        end
        lastCall = tmr.now()
    end
end

function colorWipe(delay, r, g, b)
    if printPixelBody ~= nil then return false end
    
    printPixelBody = coroutine.create(function()
        for i=0,pixels do
            setPixelColor(i, r, g, b)
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end)
    
    tmr.alarm(pxlTmrSlot, 1, 1, function() printPixels(delay) end)
    return true
end

function rainbowCycle(delay, turns)
    if printPixelBody ~= nil then return false end
    
    printPixelBody = coroutine.create(function()
        for i=0,255*turns do
            for p=0,pixels do
                setPixelColor(p, wheel((p*255/pixels+i) % 256))
            end
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end)
    
    if delay < 10 then delay = 10 end
    tmr.alarm(pxlTmrSlot, 1, 1, function() printPixels(delay) end)
    return true
end

function rainbow(delay)
    if printPixelBody ~= nil then return false end
    
    printPixelBody = coroutine.create(function()
        for i=0,255 do
            wsString = string.char(wheel(i)):rep(pixels)
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end)

    if delay < 10 then delay = 10 end
    tmr.alarm(pxlTmrSlot, 1, 1, function() printPixels(delay) end)
    return true
end

function rainbowStart(delay)
    if printPixelBody ~= nil then return false end
    
    printPixelBody = coroutine.create(function()
        i = 0
        while true do
            wsString = string.char(wheel(i)):rep(pixels)
            ws2812.writergb(wsPin,wsString)
            i = (i+1) % 256
            coroutine.yield()
        end
    end)
    
    if delay < 10 then delay = 10 end
    tmr.alarm(pxlTmrSlot, 1, 1, function() printPixels(delay) end)
    return true
end

-- not working
function chBright(bright)
        bright = (bright > 100) and 100	-- saturate
		bright = (bright < 0)	and 0
		wsString = wsString:gsub(".", function(p)
			return string.char(string.byte(p)*bright/100)
		end)
        ws2812.writergb(wsPin,wsString)
end

function forceStop()
    tmr.stop(pxlTmrSlot)
    printPixelBody = nil
    ws2812.writergb(wsPin,string.char(0):rep(pixels*3))
end

function wheel(pos)
    pos = 255-(pos%256)
    if pos < 85 then return 255-pos*3, 0, pos*3 end
    pos = pos-85
    if pos < 85 then return 0, pos*3, 255-pos*3 end
    pos = pos-85
    return pos*3, 255-pos*3, 0
end
