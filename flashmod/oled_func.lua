local oled = {MOD_NAME = "oled"}

function oled:clear()
	self:command(0x20,0x01)
	for i=0,32 do
		self:data(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	end
	self:command(0x20,0x02)
end

function oled:on()
	self:command(0xAF)
end

function oled:off()
	self:command(0xAE)
end

function oled:invert(state)
	self:command(state == 1 and 0xA7 or 0xA6)
end

function oled:scroll(start, stop, left)
	self:command(left == 1 and 0x26 or 0x27,0X00,start,0X00,stop,0X00,0XFF,0x2F)
end

function oled:scroll_stop()
	self:command(0x2E)
end

function oled:writeBig(str, x, y)
	file.open("font8x16.fnt")
	for i=1,#str do
		self:set_pos(x, y)
		local start = (string.byte(str,i) - 0x20)*16
		file.seek("set", start)
		local bits = file.read(16)
		self:data(string.byte(bits,1,8))
		self:set_pos(x, y + 1)
		self:data(string.byte(bits,9,16))
		x = x + 8
		if x > 120 then x = 0; y = y + 2 end
	end
	file.close()
end

flashMod(oled)
