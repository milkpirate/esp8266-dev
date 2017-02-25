if telnet_srv ~= nil then telnet_srv:close() end
print("Starting telnet server: "..wifi.sta.getip()..":2323")
telnet_srv = net.createServer(net.TCP, 300) -- timeout = 5min
telnet_srv:listen(2323, function(socket)
    local fifo = {}
    local fifo_drained = true

    local function sender(c)
        if #fifo > 0 then c:send(table.remove(fifo, 1))
        else fifo_drained = true end
    end

    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    local client = socket:getpeer()
    print("Telnet client connected. Giving control to "..client..".")
    client = nil
    node.output(s_output, 0)   -- re-direct output to function s_ouput.

    socket:on("receive", function(c, l) node.input(l) end)
    socket:on("sent", sender)
    
    socket:on("disconnection", function()
        node.output(nil)
        print("Telnet client disconnected.")
    end)

    print("Welcome to espClock")
end)