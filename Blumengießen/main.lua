hum = nil
tmp = nil

apiKeyW = 'XRGBGSTGQ9NWR29P'
apiKeyR = 'YPS9SPPY1JGXFGGI'
pass    = '24a4acf5'

waterPin    = 4
btnPin      = 3

tmrRead     = 6
tmrSend     = 5
tmrWatr     = 4
tmrPerd     = 3

onTime  = 0
wtrTime = 60

gpio.mode(btnPin,   gpio.INT)
gpio.trig(btnPin,   "down", checkWater(1))
gpio.mode(waterPin, gpio.OUTPUT)

humMin, humMax = rwHum("hum_level.txt")

function rwHum(file, hmin, hmax)
    if hmin ~= nil and hmax ~= nil then
        if file.open(file, "w") then
            file.writeline(hmin)
            file.writeline(hmax)
            file.close()
            return 0
        else
            return -2
        end         
    elseif hmin == nil and hmax == nil then
        if file.open(file, "r") then
            humMin = file.readline()
            humMax = file.readline()
            file.close()
            return tonumber(humMin, 10), tonumber(humMax, 10)
        else
            return 80, 110
        end
    else
        return -1
    end
end

function readData()
    uart.write(0, "read")                               -- request sensor data from arduino
    uart.on("data", "\n", function(data)                -- stop when '\n' is received.
        if string.match(data, ";") then
            tmp, hum = data:match("([^,]+);([^,]+)")    -- format = tt,t;hhhhh or hhhhh
            hum = tonumber(hum, 10)
        else
            hum = tonumber(data, 10)
        end
    end, 0)
end

function sendData(hum, tmp)
    conn=net.createConnection(net.TCP, 0) 
    -- conn:on("receive", function(conn, payload) end)
    conn:connect(80,'api.thingspeak.com')   -- api.thingspeak.com 184.106.153.149
    conn:send("GET /update?key="..apiKeyW
    if tmp ~= nil then conn.send("&field1="..tmp) end
    conn:send("&field2="..hum.." HTTP/1.1\r\n") 
    conn:send("Host: api.thingspeak.com\r\n")
    conn:send("Accept: */*\r\n")
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",function(conn) conn:close() end)
    -- conn:on("disconnection", function(conn) end)
end

function checkWater(force)
    if hum < humMin or force:
        gpio.write(waterPin, gpio.HIGH)
        onTime = tmr.time()
        tmr.alarm(tmrWatr, 1000*wtrTime, 0, function()
            gpio.write(waterPin, gpio.LOW)
            onTime = 0
        end)
    end
end

function stopWater()
    gpio.write(waterPin, gpio.HIGH)
    onTime = 0
    tmr.stop(tmrWatr)
end

uart.setup(0, 115200, 8, 0, 1, 0)                                   -- UART = 115200 8N1
readData()                                                          -- read first values
humMin, humMax = rwHum("hum_level.txt")                             -- read min,max humd.
tmr.alarm(tmrRead, 1000,           1, function() readData()         end)  -- read read data every 1s
tmr.alarm(tmrSend, 14400000,       1, function() sendData(hum, tmp) end)  -- send to thingspeak every 4h
tmr.alarm(tmrPerd, 1000*wtrTime*5, 1, function() checkWater()       end)  -- send to thingspeak every 4h
