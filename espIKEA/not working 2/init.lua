-- change baud rate
--print("Changing baudrate to 115200Bd...")
--uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)

-- new ip config
local dIP = 245

-- Begin WiFi configuration
local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.AP              -- access point: create a WiFi network
-- wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATIONAP  -- both station and access point

wifiConfig.accessPointConfig = {}
wifiConfig.accessPointConfig.ssid =		"Helios"	-- Name of the SSID you want to create
wifiConfig.accessPointConfig.pwd =		"Hyperion"	-- WiFi password - at least 8 characters
wifiConfig.stationPointConfig = {}
wifiConfig.stationPointConfig.ssid =	"<ssid>"                        -- Name of the WiFi network you want to join
wifiConfig.stationPointConfig.pwd =		"<pass>" -- Password for the WiFi network

-- Tell the chip to connect to the access point

wifi.setmode(wifiConfig.mode)
print('set ', '(mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
print('AP pass: ',wifiConfig.accessPointConfig.pwd)
print('Sta pass: ',wifiConfig.stationPointConfig.pwd)

wifi.ap.config(wifiConfig.accessPointConfig)
wifi.sta.config(wifiConfig.stationPointConfig.ssid, wifiConfig.stationPointConfig.pwd)
wifiConfig = nil
collectgarbage()
-- End WiFi configuration

-- Connect to the WiFi access point.
-- Once the device is connected, you may start the HTTP server.

local jcnt, jmax = 1,5

tmr.alarm(0, 1000, 1, function()
    local ip = wifi.sta.getip()
    if ip == nil and jcnt <= jmax then
        print('Connecting to WiFi Access Point... '..jcnt)
        jcnt = jcnt+1
    else
        tmr.stop(0)
        if jcnt > jmax then
            print('Failed to connect to WiFi Access Point.')
        else
            wifi.sta.setip({ip=ip:gmatch('%d+.%d+.%d+.')()..dIP})
            print('Sta: ',wifi.sta.getip())
            print('AP:  ',wifi.ap.getip())
            if file.open("main.lua","r") then
                file.close()
				print("Start main.lua in 1s...")
				tmr.alarm(0, 1000, 0, function() dofile("main.lua") end)
            else
                print("main.lua not found.")
            end
        end
		dIP, ip, jcnt, jmax = nil, nil, nil, nil
        collectgarbage()
    end
end)

collectgarbage()
