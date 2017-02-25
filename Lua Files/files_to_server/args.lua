return function (connection, args)
    if file.open("../color_mini.html", "r") then
        repeat
            local line=file.readline() 
            if line then
                connection:send(line);
            end
        until not line 
        file.close();
        
        if args["color"] ~= nil then
            local r,g,b
            r = string.sub(h,1,2)
            g = string.sub(h,3,4)
            b = string.sub(h,5,6)
            r = tonumber(r,16)
            g = tonumber(g,16)
            b = tonumber(b,16)
            
            ws2812.writergb(4, string.char(r,g,b):rep(2))
         end
    else
        connection:send("Page not found")
    end
end