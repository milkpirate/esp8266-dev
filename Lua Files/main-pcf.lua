-- constants
	-- I2C related
pinSDA		= 3
pinSCL		= 4
pinBTN		= 0
pinRLY		= 1

addrPCF		= 0x20
statePCF	= 0
writePCF	= 2^pinBTN

-- main program
func_init()
i2c_init()
i2c_scan()

tmr.alarm(6, 100, 1,	-- pcf r/w hadler
	function()
		statePCF = string.byte(i2c_read(addrPCF))	-- read actual state of pcf
	end
)

tmr.alarm(5, 100, 1,	-- manual button press handler
	function()
		if(bit.band(statePCF, 2^pinBTN) == 0) then
			i2c_write(addrPCF, 0, bit.bor(statePCF, 2^pinRLY))	-- toggle pin on
			-- tmr.delay(10000)									-- 10ms delay
			-- i2c_write(addrPCF, 0, statePCF)					-- toggle pin off
		end
	end
)

function colorcircle(dly)
	local length = 2
	for j=1,3 do
		for i=0,255		do ws2812.writergb(4, string.char(255,i,0):rep(length) ) delay_ms(dly) end
		for i=255,0,-1	do ws2812.writergb(4, string.char(i,255,0):rep(length) ) delay_ms(dly) end
		for i=0,255		do ws2812.writergb(4, string.char(0,255,i):rep(length) ) delay_ms(dly) end
		for i=255,0,-1	do ws2812.writergb(4, string.char(0,i,255):rep(length) ) delay_ms(dly) end
		for i=0,255		do ws2812.writergb(4, string.char(i,0,255):rep(length) ) delay_ms(dly) end
		for i=255,0,-1	do ws2812.writergb(4, string.char(255,0,i):rep(length) ) delay_ms(dly) end
	end
end


-- funtion definitions:
function func_init()
	
	-- delay functions
		-- delay_ms()	dito
		-- delay_us()	dito

	function delay_ms(milli_secs)
	   local ms = milli_secs * 1000
	   local timestart = tmr.now ( )
	   
	   while (tmr.now ( ) - timestart < ms) do
		  tmr.wdclr ( )
	   end
	end

	function delay_us(micro_secs)
	   local timestart = tmr.now ( )

	   while (tmr.now ( ) - timestart < micro_secs) do
		  tmr.wdclr ( )
	   end
	end

	-- i2c functions
		-- i2c_init()
		-- i2c_read(dvc, reg)
		-- i2c_write(dvc, reg, val)
		-- i2c_scan()
	
	function i2c_init()
	--	i2c.setup(id, pinSDA, pinSCL, speed)
		i2c.setup(0, pinSDA, pinSCL, i2c.SLOW)
	end

	function i2c_read(dvc, reg)
		i2c.start(0)
		if reg ~= nil then
			i2c.address(0, dvc ,i2c.TRANSMITTER)
			i2c.write(0, reg)
			i2c.stop(0)
			i2c.start(0)
		end
		i2c.address(0, dvc, i2c.RECEIVER)
		local c = i2c.read(0,1)
		c = tonumber(c)
		i2c.stop(0)
		return c
	end

	function i2c_write(dvc, reg, val)
		i2c.start(0)
		i2c.address(0, dvc, i2c.TRANSMITTER)
		i2c.write(0, reg)
		if val ~= nil then
			i2c.write(0, val)
		end
		i2c.stop(0)
	end

	function i2c_scan()
		print("Scanning I2C Bus...")
		local nofound = true
		for i = 0,127 do
			if (string.byte(i2c_read(i, 0))==0) then
				nofound = false
				print("device found at address: "..string.format("0x%02X",i))
			end
		end
		if nofound then
			print("No device found!")
		end
		nofound = nil
	end

	-- bitwise functions (now supported by nodemcu)
		-- bprint(val,size)
		-- bit.bxor(a,b)
		-- bit.bor(a,b)
		-- bit.bnot(n)
		-- bit.band(a,b)
		-- bit.rshift(x,by)
		-- bit.lshift(x,by)
		-- bit.arshift(x,by)
		-- bit.rol(x,by)
		-- bit.ror(x,by)
		-- bit.bswap(x)
		-- bit.tobit(x)
		-- bit.tohex(x[,n])

	function bprint(val,size)
		local mask = 2^(size -1)
		local str = ""
		while mask ~= 0 do
			if bit.band(val,mask) > 0 then
				str = str .. "1"
			else
				str = str .. "0"
			end
			mask = bit.rshift(mask, 1)
		end
		print(str)
		mask,str = nil
	end
end