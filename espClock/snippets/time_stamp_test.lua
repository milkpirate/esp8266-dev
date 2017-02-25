function err_time(err_code)
    local err_str = "unkn"
    if err_code == 1 then
        print("DNS lookup failed")
        err_str = "dnSf"
    elseif err_code == 2 then
        print("Memory allocation failure")
        err_str = "ALLf"        
    elseif err_code == 3 then
        print("UDP send failed")
        err_str = "udPf"
    elseif err_code == 4 then
        print("Timeout, no NTP response received")
        err_str = "nors"
    end
    return err_str
end

sntp.sync("3.de.pool.ntp.org", function() return end, err_time())
print(rtctime.get())

DSEC=24*60*60 -- secs in a day
YSEC=365*DSEC -- secs in a year
LSEC=YSEC+DSEC    -- secs in a leap year
FSEC=4*YSEC+DSEC  -- secs in a 4-year interval
BASE_DOW=4    -- 1970-01-01 was a Thursday
BASE_YEAR=1970    -- 1970 is the base year
TMIEZONE=1    -- UTC+1 = berlin

_days={-1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333, 364}
_lpdays={}
for i=1,2  do _lpdays[i]=_days[i]   end
for i=3,13 do _lpdays[i]=_days[i]+1 end

function gmtime(t)
--print(os.date("!\n%c\t%j",t),t)
    local y,j,m,d,w,h,n,s
    local mdays=_days
    s=t
    -- First calculate the number of four-year-interval, so calculation
    -- of leap year will be simple. Btw, because 2000 IS a leap year and
    -- 2100 is out of range, this formula is so simple.
    y= s/FSEC 
    s=s-y*FSEC
    y=y*4+BASE_YEAR         -- 1970, 1974, 1978, ...
    if s>=YSEC then
        y=y+1           -- 1971, 1975, 1979,...
        s=s-YSEC
        if s>=YSEC then
            y=y+1       -- 1972, 1976, 1980,... (leap years!)
            s=s-YSEC
            if s>=LSEC then
                y=y+1   -- 1971, 1975, 1979,...
                s=s-LSEC
            else        -- leap year
                mdays=_lpdays
            end
        end
    end
    j= s/DSEC
    s=s-j*DSEC
    local m=1
    while mdays[m]<j do m=m+1 end
    m=m-1
    local d=j-mdays[m]
    -- Calculate day of week. Sunday is 0
    w=(t/DSEC+BASE_DOW)%7
    if w == 0 then w = 7 end
    -- Calculate the time of day from the remaining seconds
    h= s/3600
    s=s-h*3600
    n=s/60
    s=s-n*60
    print("y", y)
    print("j", j+1)
    print("m", m)
    print("d", d)
    print("w", w)
    print("h", h+1)
    print("n", n)
    print("s", s)
end


