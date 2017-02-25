return function (conn, args)
    conn:send("<html><head><title>Flower Pot</title></head><body>")
    conn:send("<a href=index.lua>[main]</a> <a href=water.lua>[water]</a> <a href=config.lua>[config]</a> <a href=/>[refresh]</a><hr>")    
    conn:send("<h2>Sensors</h2><pre>")
    
    if hum == nil then  conn:send("No humidity available\n")
    else
        local str = "Humd.: "..tmp.." "
        if      hum < humMin then   str = str.."[dry]"
        elseif  hum > humMax then   str = str.."[wet]"
        else                        str = str.."[normal]"
        end
        conn:send(str.."\n")
    end
    
    if tmp == nil then  conn:send("No temperature available\n")
    else                conn:send("Temp.: "..tmp) end
    
    conn:send("\n</pre>")
    
    --[[
    local width = 450
    local height = 260
    local channel = 1
    
    conn:send("<hr align=\"left\" width=\""..width+50 .."\"">
    
    if tmp ~= nil then
        conn:send("<iframe width=\""..width.."\" height=\""..height.."\" style=\"border: 1px solid #cccccc;\" ")
        conn:send("src=\"http://api.thingspeak.com/channels/56215/charts/")
        conn:send(channel.."?&api_key="..api_key)
        conn:send("?width="..width.."&height="..height..")
        conn:send("&dynamic=true&export=true&yaxismin=10&yaxismax=40&days=7&title=Temp.\"")
        conn:send("></iframe></br>")
    end   
    
    channel = 2
    conn:send("<iframe width=\""..width.."\" height=\""..height.."\" style=\"border: 1px solid #cccccc;\" ")
    conn:send("src=\"http://api.thingspeak.com/channels/56215/charts/")
    conn:send(channel.."?&api_key="..api_key)
    conn:send("?width="..width.."&height="..height..")
    conn:send("&dynamic=true&export=true&yaxismin=10&yaxismax=40&days=7&title=Humd.\"")
    conn:send("></iframe>")
    
    conn:send("<hr align=\"left\" width=\""..width+50 .."\"">
    --]]
    
    conn:send("<hr>")
    conn:send("&copy; milkpirate\n")
    conn:send("</body></html>")
end