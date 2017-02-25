-- global vars
adc_vals    = {}
adc_num     = 8

TZ = 1
alerts = {["20:00"]=1, ["16:30"]=1}

pwml.aM = 200
pwml.am = 15
pwml.pM = 1023
pwml.pm = 16
pwml.e  = 0.4
pwml.a  = 0.01
pwml.b  = 1

-- set brightness
pwm.setup(pwml.pin, 1000, 1023-pwml.pM)
pwm.start(pwml.pin)

shift_int   = 0
bit_sec     = 0x00800000    --bit.bit(23)

--bit_syc     = 0x00000080  --bit.bit(7)
--bit_sub     = 0x00008000  --bit.bit(15)
--bit_dst     = 0x80000000  --bit.bit(31)

mqtt_topic  = "sensor/lum/bedroom"
mqtt_status = -5
tmp, tmp, mqtt_broker = wifi.sta.getip()
tmp = nil
mqtt_broker = mqtt_broker:sub(0,#mqtt_broker-1)..2

thing_api = '<api_key>'

for i=1,adc_num do 
    table.insert(adc_vals, adc.read(0))
end
adc_num = nil

-- convert time str to shiftable integer
function conv_time_int(time) -- takes 4 digit time str
    local dh,oh,dm,om
    local dig1 = {[0]=0x7B,[1]=0x60,[2]=0x5D,[3]=0x75,[4]=0x66, -- [0]=0x7B
                  [5]=0x37,[6]=0x3F,[7]=0x61,[8]=0x7F,[9]=0x77}
    local dig24= {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x6E,[4]=0x4B,
                  [5]=0x67,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x6F}
    local dig3 = {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x5E,[4]=0x4B,
                  [5]=0x57,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x5F}

    dh = tonumber(time:sub(1,2))    -- get hrs
    dh = (dh+TZ)%24                 -- timezone adjustment
    time = dh..time:sub(3)          -- write back hrs
    if(dh < 10) then time = "0"..time end

    --print(time)
    
    dh = string.byte(time:sub(1,2)) - 48
    oh = string.byte(time:sub(2,2)) - 48
    dm = string.byte(time:sub(4,4)) - 48
    om = string.byte(time:sub(5,5)) - 48

    --print(time,dh,oh,dm,om)
    
    dh = dig1[dh]
    oh = dig24[oh]
    dm = dig3[dm]
    om = dig24[om]

    shift_int = shift_int+bit_sec
    return dh+bit.lshift(oh,8)+bit.lshift(dm,16)+bit.lshift(om,24)
end

-- get time by page header from time.is
function get_time()
    --local req = "HEAD / HTTP/1.1\r\nHost: time.is\r\n"..
    --            "User-Agent: ESP8266\r\n\r\n"
    local req = "HEAD / HTTP/1.1\r\nHost: google.com\r\n"..
                "User-Agent: ESP8266\r\n\r\n"
    if conn ~= nil then conn:close() end    -- close old connection
    conn=net.createConnection(net.TCP, 0)
    conn:on("connection",function(conn, payload) conn:send(req) end)  
    conn:on("receive", function(conn, payload)
        --print(payload)
        local cutpos = string.find(payload,"Date:")+23
        local time = string.sub(payload,cutpos,cutpos+7)
        --local cutpos = string.find(payload,"Expires: ")
        --local time = string.sub(payload,cutpos+9,cutpos+33)
        local time_adjust = tonumber(time:sub(#time-1,#time)) -- get seconds
        tmr.interval(5, 60000-1000*time_adjust) -- adjust timer interval
        
        print('got time: '..time..' +'..TZ.."h (TZ)")
        print('next get in: '..(60-time_adjust)..'s')

        time = time:sub(#time-7,#time-3) -- to 4 digit time string        
        shift_int = conv_time_int(time)
        spi_write(shift_int)
        
        -- blink if alarm occures
        if alerts[time] ~= nil then
            pwm.setclock(pwml.pin, 2)
            tmr.alarm(4, 30000, tmr.ALARM_SINGLE, function()
                pwm.setclock(pwml.pin, 1000)
            end)
        end
        
    end)
    --conn:connect(80,"time.is")
    conn:connect(80,"google.com")
end

-- start sec timer to blink
tmr.alarm(6, 1000, tmr.ALARM_AUTO, function()
    table.remove(adc_vals, 1)
    table.insert(adc_vals, adc.read(0))
        
    local lum = 0
    for i=1,table.getn(adc_vals) do lum = lum + adc_vals[i] end
    lum = math.floor(lum / table.getn(adc_vals))
    if mqtt_status == 0 then m:publish(mqtt_topic, lum, 0, 1) end
    --local adcval = lum

    if lum < pwml.am then lum = pwml.pm end
    if lum > pwml.aM then lum = pwml.pM end
    if lum > pwml.am and  lum < pwml.aM then
        lum = pwml.a + ( (pwml.b - pwml.a)*(lum - pwml.am) ) / (pwml.aM - pwml.am)    -- [am,aM] -> [a,b]
        lum = math.pow(lum, pwml.e)                                                 -- gamma correction
        lum = pwml.pm + ( (pwml.pM - pwml.pm)*(lum - pwml.a) ) / (pwml.b - pwml.a)  -- [a,b] -> [pm, pM]
        lum = math.ceil(lum)
    end
    --print(adc.read(0), adcval, lum)
    pwm.setduty(pwml.pin,1023-lum)
    
    shift_int = bit.bxor(shift_int,bit_sec)  -- toggle sec led
    spi_write(shift_int)
end)

-- get time every ~1min
tmr.alarm(5, 60000, tmr.ALARM_AUTO, function()
    get_time()
    speak_lum()
end)

-- tell user we are syncing
shift_int = 0x37+bit.lshift(0x6b,8)+bit.lshift(0x62,16)+bit.lshift(0x32,24) --SYnC
spi_write(shift_int)

m = mqtt.Client("espClock", 120)
m:connect(mqtt_broker, 1883, 0, 1, function(client)
    print("MQTT connected")
    mqtt_status = 0
    m:subscribe(mqtt_topic, 0, function()
        tmr.unregister(5)
        tmr.alarm(5, 60000, tmr.ALARM_AUTO, function()
            get_time()
            local lum = speak_lum()
            m:publish(mqtt_topic, lum, 0, 1)
        end)
    end)
end, function(client, reason)
    mqtt_status = reason
    print("Failed reason: "..reason)
end)
mqtt_broker = nil

-- set up thingspeak
function speak_lum()
    local lum = 0
    for i=1,table.getn(adc_vals) do lum = lum + adc_vals[i] end
    lum = math.floor(lum / table.getn(adc_vals))

    local req = ("https://api.thingspeak.com/update?api_key=%s&field1=%s"):format(thing_api, lum)
    http.get(req, nil, function(code, data)
        if code == 200 then print( ("spoken lum: %s (ret: %s)"):format(lum, data) )
        else print("Post failed:", code, data) end
    end)
    return lum
end

-- start first time
get_time()
speak_lum()

collectgarbage()
