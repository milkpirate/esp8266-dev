local req = ...
file.open(req.fileName, "w+")
local block = req.body
print("body", req.body)
repeat
	file.write(block)
	block = coroutine.yield(1)
	print(block)
until not block
file.close()