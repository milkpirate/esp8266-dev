-- check light state and turn it off if neccessary
gpio.mode(4, gpio.INPUT)
if gpio.read(4) == 1 then
    gpio.write(3, 0) 
    tmr.delay(100)
    gpio.write(3, 1)
end
gpio.mode(4, gpio.OUTPUT, gpio.FLOAT)

-- Begin WiFi configuration
local wifi_conf = {}

-- wifi.STATION        -- station: join a WiFi network
-- wifi.SOFTAP      -- access point: create a WiFi network
-- wifi.STATIONAP   -- both station and access point
wifi_conf.mode = wifi.STATIONAP  -- both station and access point

wifi_conf.ap_conf = {}
wifi_conf.ap_conf.ssid =    "Helios"    -- Name of the SSID you want to create
wifi_conf.ap_conf.pwd =     "Hyperion"  -- WiFi password - at least 8 characters
wifi_conf.sta_conf = {}
wifi_conf.sta_conf.ssid =   "<ssid>"                        -- Name of the WiFi network you want to join
wifi_conf.sta_conf.pwd =    "<pass>" -- Password for the WiFi network
wifi_conf.sta_conf.dip =    245

-- Tell the chip to connect to the access point
wifi.setmode(wifi_conf.mode)

print('Heap: ',node.heap())
print('AP SSID: ',wifi_conf.ap_conf.ssid)
print('AP PASS: ',wifi_conf.ap_conf.pwd)
print('Connect to STA:', wifi_conf.sta_conf.ssid..'...')

wifi.ap.config(wifi_conf.ap_conf)
wifi.sta.config(wifi_conf.sta_conf.ssid, wifi_conf.sta_conf.pwd)
-- End WiFi configuration

local jcnt,jmax = 1,10

tmr.alarm(0, 1000, 1, function()
    local ip = wifi.sta.getip()
    if ip == nil and jcnt <= jmax then
        print('Connecting to STA... '..jcnt)
        jcnt = jcnt+1
    else
        tmr.stop(0)
        if jcnt > jmax then
            print('Failed to connect to STA!')
            print('AP IP: ',wifi.ap.getip())
        else
            wifi.sta.setip({ip=ip:gmatch('%d+.%d+.%d+.')()..wifi_conf.sta_conf.dip})
            print('STA IP: ',wifi.sta.getip())
            print('AP IP:  ',wifi.ap.getip())
        end

        if file.open("main.lua","r") then
            file.close()
            print("Start main.lua in 1s...")
            tmr.alarm(0, 1000, 0, function() dofile("main.lua") end)
        else
            print("main.lua not found.")
        end
        
        wifi_conf, ip, jcnt, jmax = nil, nil, nil, nil
        collectgarbage()
    end
end)

collectgarbage()
