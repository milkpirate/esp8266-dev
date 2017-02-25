local function lcd_write(bits, data_mode)
  tmr.delay(1000)
  gpio.write(pin_rs, data_mode and gpio.HIGH or gpio.LOW) -- RS=0 => cmd; RS=1 => data

  for n = 1, 2 do	-- itterate over nibbles
    for i, pin in ipairs(pin_db) do
      local j = (2-n)*4 + (i-1)			-- get target bit for bits
      local val = (bit.isset(bits, j))
      gpio.write(pin, val and gpio.HIGH or gpio.LOW)
    end
    gpio.write(pin_e, gpio.HIGH)
    tmr.delay(100)
    gpio.write(pin_e, gpio.LOW)
    tmr.delay(100)
  end
  tmr.delay(data_mode and 46 or 42)
end

local function lcd_message(text)
	-- cmd=0xC0 <=> setCursor(0,1)
	text = text:gsub("\n", string.char(0xC0))
	for i = 1, #text do
		local c = text:byte(i)
		lcd_write(c, (c ~= 0xC0))
	end
end

local function lcd_init(pin_rs, pin_e, pin_db)  
	gpio.mode(pin_rs, gpio.OUTPUT)
	gpio.mode(pin_e, gpio.OUTPUT)

	for _, pin in ipairs(pin_db) do
		gpio.mode(pin, gpio.OUTPUT)
		gpio.write(pin, gpio.LOW)
	end
	
	gpio.write(pin_rs, gpio.LOW)
	for i=1,50 do tmr.delay(5000) end	-- 250ms pwr up delay
	
	gpio.write(pin_db[0], gpio.HIGH)	-- init = D4-D7=[1100] softreset
	gpio.write(pin_db[1], gpio.HIGH)
	gpio.serout(pin_e,gpio.LOW,{10,10}); tmr.delay(5000) -- init1
	gpio.serout(pin_e,gpio.LOW,{10,10}); tmr.delay(1000) -- init2
	gpio.serout(pin_e,gpio.LOW,{10,10}); tmr.delay(1000) -- init3
	
	gpio.write(pin_db[0], gpio.LOW)		-- 4bit = D4-D7=[0100]
	gpio.serout(pin_e,gpio.LOW,{10,10}); tmr.delay(5000)

	lcd_write(0x04+0x04);	-- Display ein / Cursor aus / Blinken aus
    lcd_write(0x04+0x02);	-- Cursor inkrement / kein Scrollen
    lcd_write(0x20+0x08);	-- 4-bit Modus / 2 Zeilen / 5x7
	
	local cchars = {
	  0x03, 0x07, 0x0F, 0x0F, 0x1F, 0x1F, 0x1F, 0x1F,
	  0x18, 0x1C, 0x1E, 0x1E, 0x1F, 0x1F, 0x1F, 0x1F,
	  0x1F, 0x1F, 0x1F, 0x1F, 0x0F, 0x0F, 0x07, 0x03,
	  0x1F, 0x1F, 0x1F, 0x1F, 0x1E, 0x1E, 0x1C, 0x18,
	  0x1F, 0x1F, 0x1F, 0x00, 0x00, 0x00, 0x00, 0x00,
	  0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x1F, 0x1F,
	  0x1F, 0x1F, 0x1F, 0x00, 0x00, 0x00, 0x1F, 0x1F,
	  0x1F, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x1F, 0x1F
	}
	lcd_write(0x40);		-- set GCRAM adress
	for i=1,64 do lcd_write(cchars[i], 1) end	-- data
	
	lcd_write(0x01); tmr.delay(2000) -- clear display, return home
end

-- first solution, heap usage ~ 3304
local function big_digit(digit, pos)
	lcd_write(0x80+0*0x40+pos)
	
	digits = {	-- 0x20 = space
	  0x01,0x04,0x01,0x02,0x05,0x05,	-- 0
	  0x04,0x01,0x20,0x05,0xFF,0x05,    -- 1
	  0x06,0x06,0x01,0x02,0x07,0x07,    -- 2
	  0x04,0x06,0x01,0x05,0x07,0x03,    -- 3
	  0x02,0x05,0xFF,0x20,0x20,0xFF,  	-- 4
	  0xFF,0x06,0x04,0x07,0x07,0x01,    -- 5
	  0x00,0x06,0x06,0x02,0x07,0x03,    -- 6
	  0x04,0x04,0x01,0x20,0x20,0xFF,    -- 7
	  0x00,0x06,0x01,0x02,0x07,0x03,    -- 8
	  0x00,0x06,0x01,0x07,0x07,0x03,    -- 9
	}
	
	for i=1,6 do
	  lcd.write(digits[digit*6+i], 1);
	  if i == 3 then lcd_write(0x80+1*0x40+pos) end
	end
end

local function disp_time(time_str)
	local time_offset = 1
	lcd_write(0x01); tmr.delay(2000) -- clear display, return home
	
	local digit = str:sub(1,1)
	big_digit(digit, time_offset)
	digit = str:sub(2,2)
	big_digit(digit, time_offset+3)
	
	lcd_write(0x80+0*0x40+time_offset+6)
	lcd.write(0xA5, 1)
	lcd_write(0x80+1*0x40+time_offset+6)
	lcd.write(0xA5, 1)
	
	digit = str:sub(4,4)
	big_digit(digit, time_offset+7)
	digit = str:sub(5,5)
	big_digit(digit, time_offset+10)
end

local function disp_date(date_str)
	lcd_write(0x01); tmr.delay(2000) -- clear display, return home
		
	local digit = str:sub(1,1)
	big_digit(digit, 0);
	digit = str:sub(2,2)
	big_digit(digit, 3);
	
	lcd_write(0x80+1*0x40+6)
	lcd.write(0x2E, 1);
	
	digit = str:sub(4,4)
	big_digit(digit, 7);
	digit = str:sub(5,5)
	big_digit(digit, 10);
	
	lcd_write(0x80+1*0x40+6)
	lcd.write(0x2E, 1);
	
	lcd_write(0x80+1*0x40+15)
	digit = str:sub(7,8)
	lcd_message(digit)
end

-- alternative, heap usage ~ 4600
digits = {	-- 0x20 = space
  0x01,0x04,0x01,0x02,0x05,0x05,	-- 0
  0x04,0x01,0x20,0x05,0xFF,0x05,    -- 1
  0x06,0x06,0x01,0x02,0x07,0x07,    -- 2
  0x04,0x06,0x01,0x05,0x07,0x03,    -- 3
  0x02,0x05,0xFF,0x20,0x20,0xFF,  	-- 4
  0xFF,0x06,0x04,0x07,0x07,0x01,    -- 5
  0x00,0x06,0x06,0x02,0x07,0x03,    -- 6
  0x04,0x04,0x01,0x20,0x20,0xFF,    -- 7
  0x00,0x06,0x01,0x02,0x07,0x03,    -- 8
  0x00,0x06,0x01,0x07,0x07,0x03,    -- 9
}

local function disp_date(date_str)
	local month_dig = {
	  Jan="01", Feb="02", Mar="03", Apr="04",
	  May="05", Jun="06", Jul="07", Aug="08",
	  Sep="09", Oct="10", Nov="11", Dec="12"
	}
	
	local temp = date_str:sub(4,6)
	date_str = string.gsub(date_str, temp, month_dig[temp])
	date_str = string.gsub(date_str, " ", "")
	temp = date_str:sub(7,8)
	date_str = date_str:sub(1,4)

	lcd_write(0x01); tmr.delay(2000) -- clear display, return home
	for digit=1,4 do
	  local date_digit = tonumber(date_str:sub(digit,digit))
	  for letter_bits=1,3 do lcd_write(digits[date_digit*6+letter_bits].." ", 1) end
	end
	lcd_write(0x80+1*0x40+0) -- next line
	for digit=1,4 do
	  local date_digit = tonumber(date_str:sub(digit,digit))
	  for letter_bits=4,6 do lcd_write(digits[date_digit*6+letter_bits].." ", 1) end
	  if digit==2 then lcd_write(0x2E, 1) end
	end
	lcd_write(0x2E, 1)
	lcd_message(temp)
end

local function disp_time(time_str)
	time_str = string.gsub(time_str, ":", "")
	lcd_write(0x01); tmr.delay(2000) -- clear display, return home
	lcd_write(0x20, 1)	-- space
	
	for digit=1,4 do
	  local date_digit = tonumber(time_str:sub(digit,digit))
	  for letter_bits=1,3 do lcd_write(digits[date_digit*6+letter_bits],1) end
	  if digit==2 then lcd.write(0xA5,1) end
	end
	
	for digit=1,4 do
	  local date_digit = tonumber(time_str:sub(digit,digit))
	  for letter_bits=4,6 do lcd_write(digits[date_digit*6+letter_bits],1) end
	  if digit==2 then lcd.write(0xA5,1) end
	end
end
-- end

local lcd_setcursor = function(x, y) lcd_write(0x80+y*0x40+x) end

lcd_init(1, 2, {3, 4, 5, 6})
lcd_init = nil
collectgarbage()