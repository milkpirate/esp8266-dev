return function ()
	tmr.stop(6)
	gpio.mode(wsP, gpio.INPUT)
	local litSt = gpio.read(wsP)
	gpio.mode(wsP, gpio.OUTPUT)
	litSt = (litSt == 0) and 1 or 0 -- invert (inverse logic)
	tmr.start(6)
	return litSt
end
