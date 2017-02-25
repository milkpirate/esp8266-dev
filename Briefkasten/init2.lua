-- wifi.STATION     -- station: join a WiFi network
-- wifi.SOFTAP      -- access point: create a WiFi network
-- wifi.STATIONAP   -- both station and access point
local wifi_conf = {}
wifi_conf.mode = wifi.STATION  -- both station and access point
wifi_conf.sta_conf = {}
wifi_conf.sta_conf.ssid =   "<ssid>"                       	-- Name of the WiFi network you want to join
wifi_conf.sta_conf.pwd =    "<pass>"	-- Password for the WiFi network
wifi_conf.sta_conf.dip =    246

local PBdevId = 		"<devID>"	-- device ID
local sendMaxTries =	5	-- max retries to send msg
local sendActTries =	0	-- actual retries to send msg
local Vbat = 			0	-- battery voltage
local sleep_time =      0   -- [us] 0=forever
stayON =                0   -- shall we stay powered?

-- adc init
if adc.force_init_mode(adc.INIT_ADC) then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end
Vbat = (49000*adc.read(0))/10240	-- read battery voltage [mV]
-- end adc init

-- wifi init
wifi.setmode(wifi_conf.mode)
print('sta ssid: ',wifi_conf.sta_conf.ssid)
print('sta pass: ',wifi_conf.sta_conf.pwd)
print('connect to sta:', wifi_conf.sta_conf.ssid..'...')
wifi.sta.config(wifi_conf.sta_conf.ssid, wifi_conf.sta_conf.pwd)
-- end wifi init

-- stayON msg
if file.open("stayON", 'r') then
	file.close()
	stayON = 1
	print('found the "stayON" file. we drop to terminal then.')
else
	print('to stay on and drop to terminal type "stayON = 1"')
end
-- end stayON msg

-- msg drop function
function sendMessage()
	http.get("http://api.pushingbox.com/pushingbox?devid="..PBdevId.."&vbat="..Vbat, nil, function(code, data)
		if code ~= 200 then
			sendActTries = sendActTries + 1
			if sendActTries < sendMaxTries then
			    tmr.alarm(1, 5000, 0, function() sendMessage() end)
			else sleep() end
		else
			print("message successfully droped")
			sleep()
		end
	end)
end

-- sleep init
function sleep()
	print('i go to bed in 5secs. you can still stop me by typing "stayON = 1"')
	tmr.alarm(1, 5000, 0, function()      
        if stayON ~= 0 then
            print("ok ok... no sleep for me...")
        else
            print("...zzzzzZZZZZ")
	        node.dsleep(sleep_time,1)    -- wake up with RF cal
            return
        end
	end)
end
	
-- start to connect
local jcnt,jmax = 1,20
tmr.alarm(0, 1000, 1, function()
    local ip = wifi.sta.getip()
    if ip == nil and jcnt <= jmax then
        print('connecting to sta... '..jcnt)
        jcnt = jcnt+1
    else
        tmr.stop(0)
        if jcnt > jmax then
            print('failed to connect to sta! i go to sleep again in 5sec.')
            sleep()
        else
            wifi.sta.setip({ip=ip:gmatch('%d+.%d+.%d+.')()..wifi_conf.sta_conf.dip})
            print('sta ip: ',wifi.sta.getip())
			print("battery: ", Vbat.." mV")
			print("drop message to PushingBox...")
			sendMessage() -- if success then sleep
        end
        wifi_conf, ip, jcnt, jmax = nil, nil, nil, nil
        collectgarbage()
    end
end)

collectgarbage()
