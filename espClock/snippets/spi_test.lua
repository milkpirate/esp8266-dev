latch_pin = 2

gpio.mode(latch_pin, gpio.OUTPUT)
gpio.write(latch_pin, gpio.LOW)
result = spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
print(result)

function spi_print()
    i = 0x55
    for j=1,10 do
        spi.send(1, i)
        gpio.write(latch_pin, gpio.HIGH)
        gpio.write(latch_pin, gpio.LOW)
        tmr.wdclr();
        tmr.delay(100000);
        tmr.wdclr();
        i = bit.bnot(i)
    end
end

function spi_write(i)
    spi.send(1, i)
    gpio.write(latch_pin, gpio.HIGH)
    gpio.write(latch_pin, gpio.LOW)
end