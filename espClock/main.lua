-- main.lua
local Strt = 0x37+bit.lshift(0x33,8)+bit.lshift(0x22,16)+bit.lshift(0x33,24)
spi_write(Strt)
Strt = nil

local compile_exc = 0
local file_list = {"clock", "telnet_srv"}

for n, file_name in pairs(file_list) do
    if file.open(file_name..".lua") then
        file.close()
        file.remove(file_name..".lc")
        print("Compiling: "..file_name..".lua")
        node.compile(file_name..".lua")
    else
        print(file_name..".lua could not be found!")
    end

    if compile_exc == 1 then
        file_name = file_name..".lc"
    else
        file_name = file_name..".lua"
    end
    
    if file.open(file_name) then
        file.close()
        print("Starting: "..file_name.."...")
        dofile(file_name)
    else
        print(file_name.." could not be found!")
    end
end

collectgarbage()
