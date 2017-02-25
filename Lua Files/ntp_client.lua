--[[

Hi,
Attached ntp.lua(.txt) can be used to get the current time from a NTP-Server or to keep a table-structure (hour,minute and second) constantly sync'ed (using a timer-function)

To run the 'realtime-daemon ;)':
Code: Select all
TIME=loadfile("ntp.lua")()
TIME:run(1,10,1800,"193.170.62.252")

will start a timer that:
- uses timer 1
- updates the internal 'clock' every 10 seconds
- and adjusts the clock every 30minutes (using an address from 3.at.pool.ntp.org)
(timeserver - ip can be omitted when 'ntpserver' inside the code is set)
Global TIME.hour TIME.minute and TIME.second will constantly be updated then..
Once started, you can save some memory be setting TIME.run=nil

For a one-time call use:
Code: Select all
loadfile("ntp.lua")():sync(function(T) end)

The function passed to :sync() will be called with a table as argument (T.hour T.minute T.second) once the NTP-server answered

Important: the program currently needs an internal timer (configurable in the source) for 'guarding' the udp-call against memory leakage.
Maybe this can be changed by setting up a single 'connect' and 'receive-handler' on startup but i haven't tried yet ;)

To be honest, the 'full daemon' probably eats too much ram to be combined with 'real' work but perhaps you can tailor it to your needs...

Thomas

-- for a continuous run:
-- TIME=loadfile("ntp.lua")()
-- TIME:run(timer,updateinterval,syncinterval,[ntp-server])
-- TIME.hour TIME.minute TIME.second are updated every 'updateinterval'-seconds
-- NTP-server is queried every 'syncinterval'-seconds
--
-- a one-time run:
-- loadfile("ntp.lua")():sync(function(T) print(T:show_time()) end)
--
-- config:
-- choose a timer for udptimer
-- choose a timeout for udptimeout 
--    timer-function to close connection is needed - memory leaks on unanswered sends :(
-- set tz according to your timezone
-- choose a NTP-server near you and don't stress them with a low syncinterval :)
--
--]]

return({
	hour=0,
	minute=0,
	second=0,
	lastsync=0,
	ustamp=0,
	tz=1,
	udptimer=2,
	udptimeout=1000,
	ntpserver="193.170.62.252",
	sk=nil,
	sync=function(self,callback)
		-- print("SYNC " .. self.ustamp .. " " .. self.ntpserver)
		-- request string blindly taken from http://arduino.cc/en/Tutorial/UdpNTPClient ;)
		local request=string.char( 227, 0, 6, 236, 0,0,0,0,0,0,0,0, 49, 78, 49, 52,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		)
		self.sk=net.createConnection(net.UDP, 0)
		self.sk:on("receive",function(sck,payload) 
			-- tmr.stop(self.udptimer)
			sck:close()
			self.lastsync=self:calc_stamp(payload:sub(41,44))
			self:set_time()
			if callback and type(callback) == "function" then 
				callback(self)
			end
			collectgarbage() collectgarbage()
			-- print("DONE " .. self.ustamp)
		end)
		self.sk:connect(123,self.ntpserver)
		tmr.alarm(self.udptimer,self.udptimeout,0,function() self.sk:close() end)
		self.sk:send(request)
	end,
	calc_stamp=function(self,bytes)
		local highw,loww,ntpstamp
		highw = bytes:byte(1) * 256 + bytes:byte(2)
		loww = bytes:byte(3) * 256 + bytes:byte(4)
		ntpstamp=( highw * 65536 + loww ) + ( self.tz * 3600)	-- NTP-stamp, seconds since 1.1.1900
		self.ustamp=ntpstamp - 1104494400 - 1104494400 		-- UNIX-timestamp, seconds since 1.1.1970
		-- print(string.format("NTP: %u",ntpstamp))
		-- print(string.format("UIX: %u",self.ustamp))
		return(self.ustamp)
	end,
	set_time=function(self)
		self.hour = self.ustamp % 86400 / 3600
		self.minute = self.ustamp % 3600 / 60
		self.second = self.ustamp % 60
		-- print(string.format("%02u:%02u:%02u",hour,minute,second))
	end,
	show_time=function(self)
		return(string.format("%02u:%02u:%02u",self.hour,self.minute,self.second))
	end,
	run=function(self,t,uinterval,sinterval,server)
		if server then self.ntpserver = server end
		self.lastsync = sinterval * 2 * -1	-- force sync on first run
		tmr.alarm(t,uinterval * 1000,1,function()
			self.ustamp = self.ustamp + uinterval
			self:set_time()
			-- print(self:show_time())
			if self.lastsync + sinterval < self.ustamp then
				self:sync()
			end
		end)
	end
})

