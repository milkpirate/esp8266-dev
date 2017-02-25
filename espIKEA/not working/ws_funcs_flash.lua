-- local private = "do not define any variables outside of a function, they will not be available when you load from flash"

function mod:init() --all functions should be referenced as mod:, the colon is important as it makes the self variable available
    self.myVar = "x" --variables should be defined with self<dot> (not colon, that is only for functions)
    self.yourVar = 42 --variables are put on the table here so we can save state without making them local to the file
end

function mod:myFunc()
    self:yourFunc(self.myVar .. "yz", self.yourVar - 12) -- functions are called with self<colon>, variables with self<dot>
end

function mod:yourFunc(me, you)
    print("I am " .. me .. " and you are " .. you)
end


-- make dly global!
local mod = {MOD_NAME = "wsFnc"}

-- coLd.lc(function)
function wsFnc:coLd(f)	
	tmr.stop(wsT)
    coBdy = nil
	coBdy = coroutine.create(f)
    if dly < 10 then dly = 10 end
    tmr.alarm(wsT, 1, 1, function()
		if (tmr.now()-ltC)/1000 > dly then  -- dly = [ms]
			if coroutine.resume(coBdy) then
				ltC = tmr.now()
			else
				tmr.stop(wsT)
				coBdy = nil
			end
		end
	end)
end

--swpClr.lc(rgb)
function wsFnc:swpClr(rgb)
    wsFnc:coLd(function()
        for i=0,pxC do
            wsS = wsS:sub(1,3*i)..rgb..wsS:sub(3*i+4)
            ws2812.writergb(wsP,wsS)
            coroutine.yield()
        end
        tmr.stop(wsT)
		coBdy = nil
    end)
end

-- chBrt.lc(brt)
function wsFnc:(brt)
    if coBdy ~= nil then return end
    brt = brt%101 -- saturation
    local wsL = wsS:gsub(".", function(p)
        return string.char((string.byte(p)*brt)/100)
    end)
    ws2812.writergb(wsP,wsL)
end

--rbCyl.lc()
function wsFnc:rbCyl()
    wsFnc:coLd(function()
        self.i = 0
        while true do
            for p=0,pxC do
				self.x = (p*255/pxC+i)%256
				if x > 170 then
					x = x-170
					x = string.char(3*x,0,255-3*x)
				elseif x > 85 then
					x = x-85
					x = string.char(0,255-3*x,3*x)
				else
					x = string.char(255-3*x,3*x,0)
				end
				wsS = wsS:sub(1,3*p)..x..wsS:sub(3*p+4) 
			end
            ws2812.writergb(wsP,wsS)
            i = i+1
            coroutine.yield()
        end
    end)
end

-- clrSrt.lc()
function wsFnc:clrSrt()
    wsFnc:coLd(function()
        self.i = 0
        while true do
			self.x = i%256
			if x > 170 then
				x = x-170
				x = string.char(3*x,0,255-3*x)
			elseif x > 85 then
				x = x-85
				x = string.char(0,255-3*x,3*x)
			else
				x = string.char(255-3*x,3*x,0)
			end
            wsS = x:rep(pxC)
            ws2812.writergb(wsP,wsS)
            i = i+1
            coroutine.yield()
        end
    end)
end

flashMod(mod)