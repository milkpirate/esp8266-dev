local oled = flashMod("oled")

function oled:set_pos(x, y)
	self:command(0xB0+y, bit.band(x, 0xf0) / 16 + 16, bit.band(x, 0x0e) + 1)
end

file.open("font6x8.fnt")
oled.font6x8 = file.read()
file.close()

function oled:write(str, x, y)
	for i=1,#str do
		self:set_pos(x, y)
		local start = (string.byte(str,i) - 0x20)*6
		self:data(string.byte(self.font6x8,start+1,start+6))
		x = x + 6
		if x > 122 then x = 0; y = y + 1 end
	end
end

return oled