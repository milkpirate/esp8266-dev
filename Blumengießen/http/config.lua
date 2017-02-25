return function (conn, args)    
    conn:send("<html><head><title>Flower Pot</title></head><body>")
    conn:send("<a href=index.lua>[main]</a> <a href=water.lua>[water]</a> <a href=config.lua>[config]</a> <a href=timer.lua>[timer]</a> <a href=water.lua>[refresh]</a><hr>")
       
    conn:send("<h2>Configuration</h2>")
    conn:send("<h3>Humidity levels</h3>")
    conn:send("<form action=config.lua>\n<pre>")
    conn:send("dry [lower level] <input size=4 name=hmin type=text value="..hum_min..">")
    conn:send("wet [upper level] <input size=4 name=hmax type=text value="..hum_max..">")
    conn:send("password: <input size=8 type=password name=pw></pre>")
    
    local hmax = args["hmax"]
    local hmin = args["hmin"]
    
    if hmax ~= nil and hmin ~= nil then
        if hmax >= hmin then conn:send("<font color=#FF0000>Wrong parameters! dry &ge; wet.</font>") end
        if args["pw"] == pass then -- check main.lua
            rwHum("hum_level.txt", hmin, hmax) -- write new humidities
            conn:send("<font color=#008800>Settings successful written.</font>")
            humMax = hmax
            humMin = hmin
        else
            conn:send("<font color=#FF0000>Wrong parameters! dry &ge; wet.</font>")
    end
    
    conn:send("<hr>\n&copy; milkpirate\n</body></html>")
end