local function parse(pl)
    pl = string.match(pl, "(.+) HTTP/")
    local meth, pl = pl:match("(%w+) (.+)")
    local i = pl:find("?")
        if i == nil then
        return meth, pl, {}
    end
    local filen = pl:sub(1, i-1)
    pl = pl:sub(i+1)
    argv = {}; i = 0
    for arg in string.gmatch(pl, "([^&]+)") do
        local nam, val = string.match(arg, "(.*)=(.*)")
        if nam ~= nil then argv[nam] = val end
        i = i + 1
    end
    return meth, filen, argv
end

return function(fname, exefile, port)
    if srv ~= nil then srv:close() end
    srv = net.createServer(net.TCP, 10)
    srv:listen(port, function(conn)
        conn:on("receive", function(conn, payload)
            local idx = 0
            local litSt
            local method, reqfile, args = parse(payload)

            print(method, reqfile)

            if method ~= "GET" then return end
            if reqfile == "/favicon.ico" then return end

            if next(args) ~= nil then
                if file.open(exefile) then
                    file.close()
                    dofile(exefile)(args)
                else
                    print(exefile.." not found!")
                end
            end

            if file.open("read_lit.lc") then
                file.close()
                litSt = dofile("read_lit.lc")()
            else
                print("read_lit.lc not found!")
                return
            end

            if not file.open(fname) then
                print("file "..fname.." not found")
                return
            else file.close(fname) end
            
            function nextChunk(c)
                local str, term
                file.open(fname)
                if file.seek("set", idx) == nil then term = true end

                str = file.read(512)

                if idx == 0 then
                    -- str = str:gsub("LUA_LGH_STT",(litSt+1)%2)
                    str = str:gsub("LUA_LGH_BTN","&#12830"..(6+litSt)..";")
                end

                c:send(str)
                idx = idx + 512
                file.close()

                if term then
                    c:close()
                    return
                end
            end
    
            conn:on("sent", nextChunk)
            nextChunk(conn)
            collectgarbage()
        end)
    end)
    
    local ip = wifi.sta.getip()
    if not ip then ip = wifi.ap.getip() end
    print("httpserver running at http://" .. ip .. ":" ..  port)
    print("serving file:", fname)
    collectgarbage()
    return srv
end
