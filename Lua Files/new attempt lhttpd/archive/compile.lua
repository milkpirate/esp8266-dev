function pht(fileName)
	file.open(fileName)
	local next = -1
	local block
	local html = true
	local readBytes = 0
	local f, error = load(function()
		if next == -1 then
			next = "<?"
			return "local req = ...\n"
		end
		block = file.read(next:sub(-1))
		if not block then return nil end
		readBytes = readBytes + #block
		local swap = block:sub(-2) == next
		if swap then block = block:sub(1, -3) end
		if html then
			block = "req.send([["..block.."]])"
		else
			block = block:gsub("^=(.*)", "req.send(%1)")
		end
		if swap then
			html = not html
			next = (html and "<?" or "?>")
		end
		print(node.heap(), readBytes, block, "\n\n")
		return block
	end)
	file.close()
	collectgarbage("collect")
	print("after collect: ", node.heap())
	if not f then
		print("Error parsing pht file: "..error)
	else
		f = string.dump(f)
		collectgarbage("collect")
		print("after dump: ", node.heap())
		file.open(fileName:sub(1,-4).."lc", "w+")
		print(#f)
		for i = 1,#f,1000 do
			print(i)
			file.write(f:sub(i, i+999))
		end
		file.close()
	end
end

print(pcall(pht, "miniide.pht"))
