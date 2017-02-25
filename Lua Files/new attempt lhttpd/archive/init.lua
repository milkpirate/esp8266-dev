dofile("compile.lua")
collectgarbage("collect")
print(node.heap())
dofile("server.lua")