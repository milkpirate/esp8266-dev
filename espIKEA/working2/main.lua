-- compile files
local files_list = {'httpserver', 'ws_funcs'}
for i, f in ipairs(files_list) do
    if file.open(f..".lua") then
        file.close()
        file.remove(f..".lc")
        print('Compiling:', f..".lua")
        node.compile(f..".lua")
    else
        print(f..".lua not found!")
        collectgarbage()
        return
    end
end
files_list = nil
collectgarbage()

if file.open("index.html") == nil then
    print("index.html not found!")
    collectgarbage()
    return
end
file.close()

-- setup ws config
litP    = 3     -- GP0 = D3
-- wsP  = 4     -- GP2 = D4 -- obsolet because lib update
pxC     = 10
dly     = 10
wsS     = string.char(0):rep(pxC*3)

gpio.mode(litP, gpio.OUTPUT, gpio.PULLUP)
ws2812.init()
ws2812.write(wsS)

-- start http server
if file.open("httpserver.lc") then
    file.close()
    if srv ~= nil then srv:close() end
    srv = dofile("httpserver.lc")()
else
    print("httpserver.lc not found")
end
