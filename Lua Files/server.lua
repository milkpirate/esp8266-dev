-- install a webserver
-- Use as : httpserver()
httpserver = function ()

  conn:on("receive",function(conn,payload)
    print(payload)
    bitz="?"
    if string.len(payload)>=6 then
     if string.sub(payload,6,8) == "x10" then
      isOn = tonumber(string.sub(payload,9,9)) == "1"

      if isOn then
        gpio.write( onBtn,gpio.HIGH)
      else
        gpio.write(offBtn,gpio.HIGH)
      end

      -- Delay a bit to give X-10 remote to see the "pushed" button
      tmr.alarm(1, 500, 0, function ()
       gpio.write( onBtn,gpio.LOW)
       gpio.write(offBtn,gpio.LOW)
      end)

     end 
    end

    reply = "Sent to X-10 remote: " .. isOn
    payloadLen = string.len(reply)
    conn:send("HTTP/1.1 200 OK\r\n")
    conn:send("Content-Length:" .. tostring(payloadLen) .. "\r\n")
    conn:send("Connection:close\r\n\r\n")
    conn:send(reply)
  end)

  conn:on("sent",function(conn)
    conn:close()
  end)
end

httpserver()

