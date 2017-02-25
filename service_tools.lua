function catFile(fname)
	if file.open(fname, "r") then
		local idx = 1
		while true do
			local prefix = tostring(idx)
			prefix = string.rep(" ", 3-#prefix)..prefix.." "
			line = readline()
			if line == nil then break end
			line = line:gsub('\n', '')
			print(prefix..line)
			idx = idx+1
		end
		file.close()
	else
		print("Cant open "..fname)
	end
end

function listFiles()
	for n,v in pairs(file.list()) do print(n,v) end
end

function replaceLineByIdxFile(fname, line, idx)
	if file.open(fname, "r") then
		file.close()
		ins = ins-1
		local line = ""
		while line ~= nil do
			file.open(fname, "r")
			line = file.readline()
			file.close()
			line = line:gsub('\n', '')
			if ins == 0 then file.writeline(" ") end
			if file.open("_/_temp", 'a+') then				
				file.writeline(line)
				file.close
			else
				print("Cant open _/_temp")
				return
			end
		end
		file.remove(fname)
		file.rename("_/_temp", fname)
	else
		print("Cant open "..fname)
	end
end

function insEptFile(fname, ins)
	if file.open(fname, "r") then
		file.close()
		ins = ins-1
		local line = ""
		while line ~= nil then
			file.open(fname, "r")
			line = file.readline()
			file.close()
			line = line:gsub('\n', '')
			if ins == 0 then file.writeline(" ") end
			if file.open("_/_temp", 'a+') then				
				file.writeline(line)
				file.close
			else
				print("Cant open _/_temp")
				return
			end
		end
		file.remove(fname)
		file.rename("_/_temp", fname)
	else
		print("Cant open "..fname)
	end
end