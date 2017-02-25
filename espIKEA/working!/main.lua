-- compile files
local files2compl = {'httpserver', 'ws_funcs', 'read_lit'}
for i, f in ipairs(files2compl) do
    if file.open(f..".lua") then
        file.close()
        --file.remove(f..".lc")
        print('Compiling:', f..".lua")
        node.compile(f..".lua")
    end
end
files2compl = nil
collectgarbage()

-- setup ws config
wsP     = 4     -- GP2
litP    = 3     -- GP0
pxC     = 10
dly     = 10
wsS     = string.char(0):rep(pxC*3)

ws2812.writergb(wsP,wsS)
gpio.mode(litP, gpio.OUTPUT)
gpio.write(litP, 0)

-- start http server
if file.open("httpserver.lc") then
    file.close()
    srv=dofile("httpserver.lc")("index.html","ws_funcs.lc",80,srv)
else
    print("httpserver.lc not found!")
end
