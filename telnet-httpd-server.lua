srv=net.createServer(net.TCP,180)
srv:listen(80,function(c) 
    c:on("receive",function(c,d) 
        --if d:sub(1,6) == "telnet" then
            -- switch to telnet service
            node.output(function(s)
                if c ~= nil then c:send("\r"..s) end
            end,0)
            
            c:on("receive",function(c,d)
                if d:byte(1) == 4 then c:close() -- ctrl-d to exit
                else node.input(d) end
                collectgarbage()
            end)
            
            c:on("disconnection",function(c)
                node.output(nil)
            end)
            
            print("Welcome to NodeMCU (press ctrl+d to quit)\n")
            print("Heap:\t"..node.heap())
            print("IP:\t"..wifi.sta.getip())
            print("\n")
            for k,v in pairs(file.list()) do
                l = string.format("%-15s",k)
                print(l.."\t\t"..v.."bytes")
            end
            print("\n")
            node.input("\r\n")
            return
        --end
        --if d:sub(1,5) == "GET /" then
            -- switch to httpd service
        --end
    end) 
end)