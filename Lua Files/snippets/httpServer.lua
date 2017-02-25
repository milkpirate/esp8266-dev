-- start a web server.  Return the web server object
function startWeb(cfg)
  -- define member variables
  local config = cfg
  local state = "inactive"
  local server = net.createServer(net.TCP)

  -- define functions
  local close = function()
    server:close()
    state = "inactive"
  end

  local getStatus = function()
    return state
  end

  local parseRequest = function(request)
    -- the first line of the request is in the form METHOD URL PROTOCOL
    _, _, method, url = string.find(request, "(%a+)%s([^%s]+)")
    _, _, path, queryString = string.find(url, "([^%s]+)%?([^%s]+)")
    if queryString then
      query = {}
      for name, value in string.gfind(queryString, "([^&=]+)=([^&=]+)") do
        query[name] = value
      end
    else
      path = url
      query = nil
    end
    return {method = method, url = url, path = path, query = query, queryString = queryString}
  end
  
  -- start listening for requests
  server:listen(80,function(s)
    s:on("receive", function(s, rawRequest)
      request = parseRequest(rawRequest)
      print("Request received: ", request.method, request.url)
      if config.pages[request.path] then
        response = config.pages[request.path](request)
        status = "200 OK"
      else
        response = "<html><body><p>" .. request.url .. " doesn't exist.</p></body></html>"
        status = "404 Not Found"
      end
      headers = "HTTP/1.1 " .. status .. "\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\nContent-Length: " .. string.len(response) .. "\r\n\r\n"
      s:send(headers .. response)
    end)
  end)
  state = "listening"

  return { getStatus = getStatus, close = close }
end
