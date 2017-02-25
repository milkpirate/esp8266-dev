--[[
pixels		= 1
wsPin		= 2
pxlTmrSlot	= 6
wsString	= string.char(0):rep(pixels*3)

gpio.mode(1, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.write(1, gpio.LOW)
gpio.write(3, gpio.HIGH)

local pxlTmrSlot = 6
local lastCall = 0
]]

function adjustBrigh(bright)
	bright = bright%100
	wsString = wsString:gsub(".", function(p)
		return string.char(string.byte(p)*bright/100)
	end)
end

function resumeCo(delay)
    if (tmr.now()-lastCall)/1000 > delay then	-- delay = [ms]
        if coroutine.resume(cobody) then
            lastCall = tmr.now()
        else
            cobody = nil
            tmr.stop(pxlTmrSlot)
        end
    end
end

function loadCo(f, delay)
    if cobody ~= nil then return false end
	cobody = coroutine.create(f)
	if delay < 10 then delay = 10 end
    tmr.alarm(pxlTmrSlot, 1, 1, function() resumeCo(delay) end)
    return true
end

function colorWipe(delay, r, g, b)
    return loadCo(function()
        for i=0,pixels do
            wsString = wsString:sub(1,3*i)..string.char(r,g,b)..wsString:sub(3*i+4)
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end, delay)
end

function rainbowCycle(delay, turns)
    return loadCo(function()
        for i=0,255*turns do
            for p=0,pixels do
				local r,g,b = wheel((p*255/pixels+i) % 256)
                wsString = wsString:sub(1,3*p)..string.char(r,g,b)..wsString:sub(3*p+4)
            end
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end, delay)
end

function rainbow(delay)
    return loadCo(function()
        for i=0,255 do
            wsString = string.char(wheel(i)):rep(pixels)
            ws2812.writergb(wsPin,wsString)
            coroutine.yield()
        end
    end, delay)
end

function rainbowStart(delay)
    return loadCo(function()
        i = 0
        while true do
            wsString = string.char(wheel(i)):rep(pixels)
            ws2812.writergb(wsPin,wsString)
            i = i+1
            coroutine.yield()
        end
    end, delay)
end

-- not working
function chBright(bright)
	if cobody ~= nil then return false end
    if bright > 100 then bright = 100 end -- saturation
    if bright < 0   then bright = 0   end
	local wsLoc = wsString:gsub(".", function(p)
        return string.char((string.byte(p)*bright)/100)
	end)
    ws2812.writergb(wsPin,wsLoc)
	return true
end

function forceStop()
    tmr.stop(pxlTmrSlot)
    printPixelBody = nil
	wsString=string.char(0):rep(pixels*3)
    ws2812.writergb(wsPin,wsString)
end

function wheel(pos)
    pos = 255-(pos%256)
    if pos < 85 then return 255-pos*3, 0, pos*3 end
    pos = pos-85
    if pos < 85 then return 0, pos*3, 255-pos*3 end
    pos = pos-85
    return pos*3, 255-pos*3, 0
end
