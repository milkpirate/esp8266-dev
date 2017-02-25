if telnet_srv ~= nil then telnet_srv:close() end
telnet_srv = net.createServer(net.TCP, 180)
telnet_srv:listen(80, function(c)
    c:on("receive", function(c, d)
        tmr.stop(6)
        if (d:sub(1,6) == string.char(255,251,31,255,251,32) or d:sub(1,5) == "file.") then
            local fifo = {}
            local fifo_drained = true

            local function sender(c)
                if #fifo > 0 then c:send(table.remove(fifo, 1))
                else fifo_drained = true end
            end
            
            local function s_output(str)
                table.insert(fifo, str)
                if c ~= nil and fifo_drained then
                    fifo_drained = false
                    sender(c)
                end
            end
            
            node.output(s_output, 0)   -- re-direct output to function s_ouput.
            
            c:on("receive",function(c,d) node.input(d) end)
            c:on("disconnection",function(c) node.output(nil) end)
            c:on("sent", sender)
            
            if d:sub(1,5) == "file." then
                c:send("HTTP/1.1 200 OK\r\n\r\n")
                --tmr.alarm(6,500,tmr.ALARM_SINGLE,function()  end )
            else
                print("Welcome to espIKEA.")
                node.input('\n')
            end
        else
            c:on("sent", function(c) c:close() end)
            c:send("Hello from http server")
        end
    end)
end)