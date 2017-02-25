local hs = node.heap()
local ts = tmr.now()

local oled = dofile("oled.lc")
collectgarbage()

local te = tmr.now()
local he = node.heap()
print("load - heap:", he-hs, "time:", (te-ts) / 1000000)

local str = ""
for i = 32,127 do str = str..string.char(i) end

hs = node.heap()
ts = tmr.now()

oled:initSPI(3)
oled:writeBig("Hello, World!1!1", 0, 0)
oled:write(str, 0, 2)

te = tmr.now()
he = node.heap()
print("display - heap:", he-hs, "time:", (te-ts) / 1000000)

--oled.scroll(0x00, 0x0f) -- start scroll

state = 0

tmr.alarm(3, 1000, 1, function() -- invert every 0.5s
	oled:invert(state)
	state = bit.bxor(state, 1)
end)

tmr.alarm(4, 30000, 0, function() -- stop scroll and clear after 4 sec
	tmr.stop(3)
	oled:scroll_stop()
	oled:clear()
	oled:invert(0)
	oled = nil
end)