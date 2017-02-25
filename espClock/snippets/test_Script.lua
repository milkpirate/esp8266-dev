dig1 =  {[0]="1111011",[1]="1100000",[2]="1011101",[3]="1110101",[4]="1100110",
         [5]="0110111",[6]="0111111",[7]="1100001",[8]="1111111",[9]="1110111"}
dig24 = {[0]="1111101",[1]="1001000",[2]="0111110",[3]="1101110",[4]="1001011",
         [5]="1100111",[6]="1110111",[7]="1001100",[8]="1111111",[9]="1101111"}
dig3 =  {[0]="1111101",[1]="1001000",[2]="0111110",[3]="1011110",[4]="1001011",
         [5]="1010111",[6]="1110111",[7]="1001100",[8]="1111111",[9]="1011111"}

--[[
dig1 = {[0]=123,[1]=96, [2]=93,[3]=117,[4]=102,
        [5]=55, [6]=63, [7]=97,[8]=127,[9]=119}
dig24= {[0]=125,[1]=72, [2]=62,[3]=110,[4]=75,
        [5]=103,[6]=119,[7]=76,[8]=127,[9]=111}
dig3 = {[0]=125,[1]=72, [2]=62,[3]=94, [4]=75,
        [5]=87, [6]=119,[7]=76,[8]=127,[9]=95}

dig1 = {[0]=0x7B,[1]=0x60,[2]=0x5D,[3]=0x75,[4]=0x66,
        [5]=0x37,[6]=0x3F,[7]=0x61,[8]=0x7F,[9]=0x77}
dig24= {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x6E,[4]=0x4B,
        [5]=0x67,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x6F}
dig3 = {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x5E,[4]=0x4B,
        [5]=0x57,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x5F}
--]]

local dig = {}
dig.1 = {[0]=0x7B,[1]=0x60,[2]=0x5D,[3]=0x75,[4]=0x66,
         [5]=0x37,[6]=0x3F,[7]=0x61,[8]=0x7F,[9]=0x77}
dig.2 = {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x6E,[4]=0x4B,
         [5]=0x67,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x6F}
dig.3 = {[0]=0x7D,[1]=0x48,[2]=0x3E,[3]=0x5E,[4]=0x4B,
         [5]=0x57,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x5F}
dig.4 = {[0]=0x00,[1]=0x48,[2]=0x3E,[3]=0x6E,[4]=0x4B,
         [5]=0x67,[6]=0x77,[7]=0x4C,[8]=0x7F,[9]=0x6F}

for i=0,9 do
  print(i, dig1[i], dig24[i], dig3[i])
end

print("----------------------------------")

for i=0,9 do
  dig1[i] = tonumber(dig1[i],2)
  dig24[i] = tonumber(dig24[i],2)
  dig3[i] = tonumber(dig3[i],2)
end

for i=0,9 do
  print(i, dig1[i], dig24[i], dig3[i])
end

print("----------------------------------")

time = "Thu Apr  5 23:50:79 CEST 2012"
--time = "Wed May 11 04:01:51 CEST 2016"
--time = "Mon Jan 12 14:46:40 CET 1970"

function time_to_int(time)
  local dig1 = {[0]=123,[1]=96, [2]=93,[3]=117,[4]=102,
                [5]=55, [6]=63, [7]=97,[8]=127,[9]=119}
  local dig24= {[0]=125,[1]=72, [2]=62,[3]=110,[4]=75,
                [5]=103,[6]=119,[7]=76,[8]=127,[9]=111}
  local dig3 = {[0]=125,[1]=72, [2]=62,[3]=94, [4]=75,
                [5]=87, [6]=119,[7]=76,[8]=127,[9]=95}
  local dh,oh,dm,om
  dh = dig1[tonumber(time:sub(12,12))]
  oh = dig24[tonumber(time:sub(13,13))]
  dm = dig3[tonumber(time:sub(15,15))]
  om = dig24[tonumber(time:sub(16,16))]
  print(time:sub(12,16), dh, oh, dm, om)
  dh = dh+bit.lshift(oh,8)+bit.lshift(dm,16)+bit.lshift(om,24)
  print(time:sub(12,16), dh)
end

print(time:sub(12,23), time:sub(23,23), bit.lshift(1,31))
time_to_int(time)
