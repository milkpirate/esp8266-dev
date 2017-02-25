return function (conn, args)
    conn:send("<html><head><title>Flower Pot</title></head><body>")
    conn:send("<a href=index.lua>[main]</a> <a href=water.lua>[water]</a> <a href=config.lua>[config]</a> <a href=water.lua>[refresh]</a><hr>")
    
    conn:send("<h2>Water</h2>\n<pre>state: ")
    
    local textState
    local textBtn
    local valWtr
    
    if onTime ~= 0 then
        local tmp = wtrTime - (tmr.time() - onTime) -- convert to secs
        tmp = tmp % (2^31-1)
        textState = "<font color=#FF0000>ON</font> [for another "..tmp.."s]"
        textBtn   = "OFF"
        valWtr    = 1
    else
        textState = "OFF"
        textBtn   = "ON"
        valWtr    = 1
    end
    
    conn:send(state)
    conn:send("<form action=water.lua>\n")
    conn:send("password: <input size=8 type=password name=pw> ")
    conn:send("<input type=submit value=\""..textBtn.."\">")
    conn:send("<input type=hidden name=wtr value="..valWtr.."><pre></form>")
    
    if args["wrt"] ~= nil then
        if args["pw"] == pass then -- check main.lua
            checkWater(1)   -- turn into file
        else
            conn:send("<font color=#FF0000>Wrong password!</font>")
        end
    end
    
    conn:send("<hr>\n&copy; milkpirate\n</body></html>")
end