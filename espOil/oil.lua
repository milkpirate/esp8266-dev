-- global vars
pin_trig	= 4
pin_echo	= 3
time_tick	= 0

-- default values
settings = {}
settings.temp_corr      = 15.0					-- [°C]
settings.lit_pro_cm     = 38.73					-- [l/cm]
settings.tank_hi        = 150.0					-- [cm]
settings.sensor_offset  = 0.0					-- [cm]
settings.tank_vol		= 4000					-- [l]
settings.update_intv	= 12					-- [hrs]
settings.avg_num		= 16					-- [#]
settings.channelid      = <ch_id>				-- [#]
settings.api_key		= "<api_key>"	-- thingspeak api key

-- read settings if available
if file.open("settings", "r") then
	settings = cjson.decode(file.read())
else
	file.open("settings", "w+")
	file.writeline(cjson.encode(settings))
	file.close()
end

-- init pins
gpio.mode(pin_trig, gpio.OUTPUT)
gpio.mode(pin_echo, gpio.INT)

-- init post connection (no disconnect handler needed, terminated by http porto)
function post_fuellung()
	local post = net.createConnection(net.TCP, 0)
	local req = "HEAD /update?api_key="..settings.api_key.."&field1="..
				settings.fuellung.." HTTP/1.1\r\nHost: api.thingspeak.com\r\n\r\n"
	post:on("connection", function(post) post:send(req) end)
	post:on("receive", function(post, pl)
		if string.find(pl, "200 OK") ~= nil then print("fuellung = "..settings.fuellung.." posted")
		else print("Post failed!") end
	end)
	post:connect(80,'api.thingspeak.com')
end

-- get time (no disconnect handler needed, terminated by http porto)
function get_time()
    local timec = net.createConnection(net.TCP, 0)
    local req = "HEAD / HTTP/1.1\r\nHost: time.is\r\nAccept: */*\r\n"..
                "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                "\r\n\r\n"
    timec:on("connection",function(timec) timec:send(req) end)  
    timec:on("receive", function(timec, pl)
        local cutpos = string.find(pl,"Expires: ")
        settings.time = string.sub(pl,cutpos+9,cutpos+33)
        print(settings.time)
    end)
    timec:connect(80,"time.is")
end

function meassure_and_post()
	local count = settings.avg_num+2			-- load counter (oversampling for remove min/max)
	local time_array	= {}					-- meassurment array
	local time_start	= 0
	
	get_time()									-- dito
	
	gpio.trig(pin_echo, "up", function()		-- setup callback functions
		time_start = tmr.now()
	end)
	gpio.trig(pin_echo, "down", function()
		time_array[count] = (tmr.now() - time_start)/2000	-- one way, convert [us]/1000 = [ms]
	end)
	
	tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()		
		gpio.serout(pin_trig,gpio.LOW,{0,100})				-- trigger next messaurement pulse time = 100[us]
		count = count-1
		if count == 0 then tmr.unregister(1) end			-- unregister if we're done
	end)

	tmr.alarm(2, 60000, tmr.ALARM_SINGLE, function()		-- start once in 60secs
		get_time()
		gpio.trig(pin_echo, "none")							-- remove callbacks again
		
		settings.fuellung = 0
		table.sort(time_array)
		for i = 2,#time_array-1 do							-- leave min & max out
			settings.fuellung = settings.fuellung + time_array[i]
		end
		time_array = nil
		
		settings.fuellung = settings.fuellung / settings.avg_num				-- avarage out [ms]
		settings.fuellung = settings.fuellung * (33.15+0.06 * settings.temp_corr)	-- [cm/ms]*[ms] = [cm]
		settings.fuellung = settings.lit_pro_cm * (settings.tank_hi + settings.sensor_offset - settings.fuellung)	-- calculate oil volume
		
		post_fuellung()											-- post fuellung
	end)
end

tmr.alarm(0, 3600000, tmr.ALARM_AUTO, function()	-- [1/hr]
	time_tick = time_tick+1
	if (time_tick % settings.update_intv) == 0 then	-- [1/(settings.update_intv)hrs]
		meassure_and_post()
	end
end)

meassure_and_post()									-- initial meassurement
collectgarbage()
