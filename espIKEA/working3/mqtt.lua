return function()
    local tmp, tmp, mqtt_broker = wifi.sta.getip()
    tmp = nil
    mqtt_broker = mqtt_broker:sub(0,#mqtt_broker-1)..2
    
    local m = mqtt.Client("espIKEA", 120)

    print(mqtt_topic)
    m:on("message", function(m,tpc,pl)
    	tpc = tpc:gsub(mqtt_topic:sub(1,#mqtt_topic-1), "")
        pl = pl:gsub("#","") -- color # removal
        print("MQTT", tpc, pl)
    	dofile("ws_funcs.lc")(tpc, pl)
    end)
    
    if m ~= nil then m:close() end
    m:connect(mqtt_broker, 1883, 0, 1, function(client)
    	print("mqtt subed to", mqtt_topic)
        m:subscribe(mqtt_topic, 1)
        mqtt_status = 0
    end, function(client, reason)
    	print("mqtt failed: "..reason)
        mqtt_status = reason
    end)
    
    mqtt_broker = nil
    collectgarbage()
    return m
end
