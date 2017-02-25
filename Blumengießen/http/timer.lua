return function (conn, args)
    conn:send("<html><head><title>Flower Pot</title></head><body>")
    conn:send("<a href=index.lua>[main]</a> <a href=water.lua>[water]</a> <a href=config.lua>[config]</a> <a href=timer.lua>[timer]</a> <a href=water.lua>[refresh]</a><hr>")
    
    conn:send("<h2>Timer</h2>")
    
    
        local tmp = wtrTime - ((tmr.time() - onTime) / 1000000) -- convert to secs

    end
    
    conn:send(state)
    conn:send("<form action=\"/water.lua\">\n")
    conn:send("password: <input size=8 type=password name=pw> ")
    conn:send("<input type=submit value=\""..textBtn.."\">")
    conn:send("<input type=hidden name=wtr value="..valWtr.."></form>")
    
    if args["wrt"] ~= nil then
        if args["pw"] == pass then -- check main.lua
            if      args["wrt"] == 1 then checkWater(1) end
            elseif  args["wrt"] == 0 then stopWater() end
            else    conn:send("<font color=#FF0000>Wrong command!</font>")
        else
            conn:send("<font color=#FF0000>Wrong password!</font>")
        end
    end
    
    conn:send("<pre><hr>\n&copy; milkpirate\n</body></html>")
end