local oled = {MOD_NAME = "oled"}

function oled:write_reg(dev_addr, reg_addr, reg_val)
     i2c.start(self.id)
     i2c.address(self.id, dev_addr, i2c.TRANSMITTER)
     i2c.write(self.id, reg_addr, reg_val)
     i2c.stop(self.id)
end

function oled:command_i2c(...)
	for i,cmd in ipairs(arg) do
		self.write_reg(self.addr, 0, cmd)
	end
end

function oled:data_i2c(...)
	for i,cmd in ipairs(arg) do
		self.write_reg(self.addr, 0, cmd)
	end
end

function oled:command_spi(...)
	gpio.write(self.dc, gpio.LOW)
	spi.send(1, arg)
end

function oled:data_spi(...)
	--print("data", unpack(arg))
	gpio.write(self.dc, gpio.HIGH)
	spi.send(1, arg)
end

function oled:initSPI(dc_n)
	self.dc = dc_n
	spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
	gpio.mode(self.dc, gpio.OUTPUT)
	
	--persist the often called command and data functions in memory
	self.command = self.command_spi
	self.data = self.data_spi
	
	self:command(0x8d,0x14,0xaf,0xd3,0x00,0x40,0xa1,0xc8,0xda,0x12,0x81,0xff,0x20,0x02)
end

function oled:initI2C(sda_n, scl_n)
	self.id = 0
	self.addr = 0x3C
	self.sda = sda_n
	self.scl = scl_n
	i2c.setup(self.id, self.sda, self.scl, i2c.SLOW)
	
	--persist the often called command and data functions in memory
	self.command = self.command_i2c
	self.data = self.data_i2c
	self.write_reg = self.write_reg
	
	self:command(0x8d,0x14,0xaf,0xd3,0x00,0x40,0xa1,0xc8,0xda,0x12,0x81,0xff,0x20,0x02)
end

flashMod(oled)
