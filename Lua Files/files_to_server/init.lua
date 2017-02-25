print("-- Configuring WIFI")
wifi.setmode(wifi.STATION)
wifi.sta.config("<ssid>", "<pass>")

local extmap = {
    html = "text/html"
}

function html2ws(h)
    local r,g,b
    r = string.sub(h,1,2)
    g = string.sub(h,3,4)
    b = string.sub(h,5,6)
    r = tonumber(r,16)
    g = tonumber(g,16)
    b = tonumber(b,16)
    return string.char(r,g,b)
end

sendFileContents = function(conn, type)
    repeat 
        local line=file.readline() 
        if line then
                conn:send(line);
        end 
    until not line 
    file.close();
end

print("-- Starting lhttpd")
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,request)
        reqdata = {};
        _, _, _, req = string.find(request, "([A-Z]+) (.+) HTTP/(%d).(%d)");
        request = nil

        local fname = "";
        if req:find("%?") then
            local rest
            _, _, fname, rest = req:find("(.*)%?(.*)");
            rest = rest .. "&";
            for crtpair in rest:gmatch("[^&]+") do
                local _, __, k, v = crtpair:find("(.*)=(.*)");
                v = v:gsub("(%%%x%x)", function(s) return string.char(tonumber(s:sub(2, -1), 16)) end);
                reqdata[k] = v;
            end
        else
            fname = req;
        end
        
        fname = (fname == "/") and "index.pht" or fname:sub(2, -1);

        s, e = fname:find("%.[%a%d]+$")
        local ftype = fname:sub(s+1, e):lower()
        s, e = nil

        ftype = (#ftype > 0 and ftype) or "txt"

        if file.open(fname, "r") then
            sendFileContents(conn,ftype)
        else
            conn:send("Page not found")
        end

        e = reqdata["color"]
        ws2812.writergb(4, html2ws(e):rep(2))
        
        _, fname, ftype, reqdata, s, e = nil, nil, nil, nil, nil

    end)

    conn:on("sent",function(conn) 
        conn:close()
        conn = nil
    end)
end)