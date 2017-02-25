-- adc settings
if adc.force_init_mode(adc.INIT_ADC) then
  node.restart()
  return
end

-- init spi shift register
pin_lat = 2
gpio.mode(pin_lat, gpio.OUTPUT)
gpio.write(pin_lat, gpio.LOW)
spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 32, 1)

--[[
nodemcu | 74HC595
--------|----------------
D7      | Data (pin 14)
D5      | Clock (pin 11)
D2      | Latch (pin 12)
--]]

function spi_write(data)
    spi.send(1, data)
    gpio.write(pin_lat, gpio.HIGH)
    gpio.write(pin_lat, gpio.LOW)
end

local Conn = 0x1b+bit.lshift(0x72,8)+bit.lshift(0x62,16)+bit.lshift(0x52,24)
local ConF = 0x1b+bit.lshift(0x72,8)+bit.lshift(0x62,16)+bit.lshift(0x17,24)
local Con  = 0x1b+bit.lshift(0x72,8)+bit.lshift(0x62,16)
local FAIL = 0x0f+bit.lshift(0x5f,8)+bit.lshift(0x21,16)+bit.lshift(0x31,24)
local dig24= {[1]=0x48,[2]=0x3E,[3]=0x6E,[4]=0x4B,[5]=0x67,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x6F}

spi_write(ConF)

local wifi_cnf = {}
wifi_cnf.ssid       = '<ssid>'
wifi_cnf.pwd        = '<pass>'
wifi_cnf.nip        = 250
wifi_cnf.hostname   = "espClock"

-- wifi.STATION         -- station: join a WiFi network
-- wifi.AP              -- access point: create a WiFi network
-- wifi.STATIONAP  -- both station and access point
wifi_cnf.mode = wifi.STATION  -- both station and access point
wifi.setmode(wifi_cnf.mode)

print('heap: ',node.heap())
print('Sta SSID:', wifi_cnf.ssid)
print('Sta PASS:', wifi_cnf.pwd)

wifi.sta.config(wifi_cnf.ssid, wifi_cnf.pwd)
-- End WiFi configuration

local jcnt,jmax = 1,9

tmr.alarm(0, 1000, 1, function()
    local ip = wifi.sta.getip()
    if ip == nil and jcnt <= jmax then
        print('Connecting to AP... '..jcnt)
        spi_write(Con+bit.lshift(dig24[jcnt],24))
        jcnt = jcnt+1
    else
        tmr.stop(0)
        if jcnt > jmax then
            print('Failed AP!')
            spi_write(FAIl)
        else
            spi_write(Conn)
            wifi.sta.sethostname(wifi_cnf.hostname)
            wifi.sta.setip({ip=ip:gmatch('%d+.%d+.%d+.')()..wifi_cnf.nip})
            print('Sta IP:', wifi.sta.getip())
            print('Sta Hostname:', wifi.sta.gethostname())
            if file.open("main.lua","r") then
                file.close()
                print("Start main.lua in 1s...")
                tmr.alarm(0, 1000, 0, function() dofile("main.lua") end)
            else
                print("main.lua not found.")
            end
        end
        ip, jcnt, jmax = nil, nil, nil, nil
        collectgarbage()
    end
end)

collectgarbage()
