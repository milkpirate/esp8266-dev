return function (connection, req, args)
	-- switch light
    if args["lit"] ~= nil then
        if args["lit"] == "1" then gpio.write(litP, 1)
        else gpio.write(litP, 0) end
        args = nil
    
    -- turn everything off
    elseif args["tot"] ~= nil then
        frcStp()
        gpio.write(litP, 0)
        args = nil
    end

    litSt = gpio.read(litP)
 
	-- &#128306;	button off
	-- &#128307;	button on
	-- &#10687;		circle off
	-- &#10686;		circle on
	-- &#8226;		dot off
	-- &#9702;		dot on
  
    if file.open("http/remote.html", "r") then
        while true do 
            local line=file.readline()
            if line == nil then break end
			line = line:gsub("LUA_LGH_STT",(litSt+1)%2)
			line = line:gsub("LUA_LGH_BTN","&#1068"..(6+litSt)..";")
            connection:send(line)
        end
    else
        connection:send("<html><head><title>404 - Not Found</title></head><body><h1>404 - Not Found</h1></body></html>")
    end
    file.close()
	
	local function chkCal(f, n)
		n = tonumber(n)
		if n ~= nil then f(n) end
	end

    -- if we still have args
    if args ~= nil then
    
        -- plain color
        if args["color"] ~= nil then
    		local clr=args["color"]:gsub("..", function(c)
    			return string.char(tonumber(c, 16))
    		end)
    		swpClr(sDly,clr)
    		clr = nil
            
        -- change brightness
        elseif args["brt"] ~= nil then
    		chkCal(chBrt,args["brt"])
    
        -- change color over time
        elseif args["rbdly"] ~= nil then
    		chkCal(rbCyl,args["rbdly"])
    		
        -- change color over time
        elseif args["ccotdly"] ~= nil then
    		chkCal(clrSrt,args["ccotdly"])
        end
    end
    
	collectgarbage()
end
