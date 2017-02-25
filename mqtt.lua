CLIENTID = "esp8266-"..node.chipid()
BRKIP  = "fritz.box"
BRKPRT = 1883
TOPIC = "gpio"

gpio.mode(4, gpio.OUTPUT)

m = mqtt.Client(CLIENTID, BROKER, 120)
m:connect(BRKIP, BRKPRT, 0, function(conn) print("connected") end)
m:subscribe(TOPIC, 0, function(conn) print("sub. to"..TOPIC) end)
-- m:publish(TOPIC, "io4="..gpio.read(4), 0, 0, function(conn) print("sending io="..gpio.read(4)) end)

m:on("message", function(conn, topic, data)
    if data == "1" then
        gpio.write(4, gpio.HIGH)
    elseif data == "0" then
        gpio.write(4, gpio.LOW)
    end
end)
