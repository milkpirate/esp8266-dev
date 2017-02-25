-- Compile server code and remove original .lua files.
local serverFiles = {'flashmod.lua', 'httpserver.lua', 'httpserver-basicauth.lua', 'httpserver-conf.lua', 'httpserver-b64decode.lua', 'httpserver-request.lua', 'httpserver-static.lua', 'httpserver-header.lua', 'httpserver-error.lua'}

for i, f in ipairs(serverFiles) do
    if file.open(f) then
    	file.close()
    	print('Compiling:', f)
    	node.compile(f)
    	file.remove(f)
    	collectgarbage()
    end
end
serverFiles = nil
collectgarbage()

-- Setup WS2812 variables and init
pxC		= 10
wsP		= 4	-- GP2
litP	= 3	-- GP0
dly     = 10
wsS		= string.char(0):rep(pxC*3)

ws2812.writergb(wsP,wsS)
gpio.mode(litP, gpio.OUTPUT)
gpio.write(litP, 0)

-- Load flashmod
local f = "flashmod.lc"
if file.open(f,"r") then
	file.close()
--	dofile(f)
else print(f.." not found!") end

-- Load WS2812 functions
f = "ws_funcs.lua"
if file.open(f,"r") then
	file.close()
	dofile(f)
else print(f.." not found!") end

-- Start HTTP server
f = "httpserver.lc"
if file.open(f,"r") then
	file.close()
	dofile(f)(80)
else print(f.." not found!") end

-- cleanup
f = nil
collectgarbage()
