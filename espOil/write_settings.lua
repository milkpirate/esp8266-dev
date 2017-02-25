return function(args)
	if args.conf == "settings" then
		args.conf = nil
		
		for n,v in pairs(args) do settings[n] = tonumber(args[n]) end
		args = nil
		
		-- convert to integer
		settings.tank_vol       = settings.tank_vol - settings.tank_vol%1
		settings.update_intv    = settings.update_intv - settings.update_intv%1
		settings.avg_num        = settings.avg_num - settings.avg_num%1
		settings.channelid      = settings.channelid - settings.channelid%1
		
		if file.open("settings", "w+") then
			file.writeline(cjson.encode(settings))
			file.close()
		end
	elseif args.conf == "wifi_conf" then
		args.conf = nil
		
		if file.open("wifi_conf", "r") then
			wifi_conf = cjson.decode(file.read())
			file.close()
		end

		wifi_conf.sta_conf.ssid = args["ssid"]
		wifi_conf.sta_conf.pwd  = args["pwd"]
		args = nil
		
		if file.open("wifi_conf", "w+") then
			file.writeline(cjson.encode(wifi_conf))
			file.close()
		end
		
		node.restart()
	end
end