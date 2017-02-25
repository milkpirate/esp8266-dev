local req=...
local compile = function(fileName)
	if fileName:sub(-4) == ".pht" then
		local o, next, block, html, pos, was, prev, mode = fileName:sub(1,-4).."lua", "?>", "local req=...?>", false, 0, false, false, "w+"
		repeat
			if block:sub(-2) == next then
				block = block:sub(1, -3)
				html = not html
				next = (html and "<?" or "?>")
			end
			block = was and "req.send([["..block.."]])\n" or prev and block:gsub("^=(.*)", "req.send(tostring(%1))").."\n" or block.."\n"
			prev = was
			was = html
			file.open(o, mode)
			file.write(block)
			file.close()
			mode = "a+"
			file.open(fileName)
			file.seek("set", pos)
			block = file.read(next:sub(-1))
			pos = file.seek("cur")
			file.close()
		until not block
		fileName = o
	end
	if fileName:sub(-4) == ".lua" then
		node.compile(fileName)
	end
	collectgarbage("collect")
end
print(req)
if not req then
	print("Compiling everything")
	for fileName, v in pairs(file.list()) do
		print(fileName, node.heap())
		if fileName~="server.lua" then
			print(pcall(compile, fileName))
		end
	end
	print("Finished compiling", node.heap())
elseif type(req) == "table" then
		node.output(function(s) req.send(s.."<br/>\n") end)
		compile(req.fileName)
		node.output(nil)
elseif type(req) == "string" then
	compile(req)
end
