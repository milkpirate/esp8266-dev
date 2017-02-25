-- init mqtt client with keepalive timer 120sec
m = mqtt.Client("clientid", 120, "user", "password")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) print ("offline") end)

-- on publish message receive event
m:on("message", function(client, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

tmp, tmp, mqqt_broker=wifi.sta.getip()
tmp = nil

m:connect(mqqt_broker, 1883, 0,
    function(client)
        print("connected")
    end, 
    function(client, reason)
        print("failed reason: "..reason)
    end
)

m:subscribe("esp8266/hum_time", 0,
    function(client)
        print("subscribe success")
    end
)

--[[
In separate terminal windows do the following:

Start the broker:

mosquitto
Start the command line subscriber:

mosquitto_sub -v -t 'test/topic'
Publish test message with the command line publisher:

mosquitto_pub -t 'test/topic' -m 'helloWorld'
As well as seeing both the subscriber and publisher connection messages in the broker terminal the following should be printed in the subscriber terminal:

test/topic helloWorld
--]]