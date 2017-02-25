-- const
ssid	= "<ssid>"
pass	= "<pass>"

-- ctrl vars
aktl_trys	= 0		-- already tried
max_trys	= 200	-- max trys to cinnect

function check_wifi() 
	if (aktl_trys > max_trys) then
		print("Sorry. Not able to connect.")
	else
		ip_addr = wifi.sta.getip()
		if ((ip_addr == nil) or (ip_addr ~= "0.0.0.0")) then
			tmr.alarm(0, 1000, 0, check_wifi)
			print("Checking WIFI..." .. aktl_trys)
			aktl_trys = aktl_trys + 1
		end
	end 
end

print("-- Starting up! ")
ip_addr = wifi.sta.getip()
if ( ( ip_addr == nil ) or  ( ip_addr == "0.0.0.0" ) ) then		-- already connected?
	-- no
	print("Configuring WIFI....")
	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid, pass)
	print("Waiting for connection")
	tmr.alarm(0 , 1000 , 0 , check_wifi)	-- call check_wifi every sec
else
	-- yes
	print("Connected to WIFI!")
	print("IP Address: " .. wifi.sta.getip())
end