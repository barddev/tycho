pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--declare variables, initalize, and start game loop

-- less confusing control buttons
btn_left=0
btn_right=1
btn_up=2
btn_down=3
btn_o=4
btn_x=5


--game physics values
gravity=0.10
friction=0.425

  
function _init()
  --start music
  music(0)
  --map information
	 map_x=0
	 map_y=0

	 map_start=0
	 map_end=256
	 
	 --game functions
  game={
    update=menu_update,
    draw=menu_draw,
  }
  
  --camera
  cam_x=0
 
  
  --player
  p={
    --sprite
    sp=2,
    --animation timing
    anim=0,
    --sprite x position
    x=64,
    --sprite y position
    y=64,
    --flip sprit horizontal
    flp=false,
    --sprite width/height in pixel
    w=8,
    h=8,
    --player x speed
    dx=0,
    max_dx=1,
    acc_x=0.25,
    --player y speed
    dy=0,
    max_dy=1.5,
    acc_y=2,
    --player states
    --idle, running, jumping, falling
    state="idle",
    shooting=false
  }

end

function _update60()
  game.update()
end

function _draw()
  game.draw()
end
-->8
--menu

function menu_update()
  if btnp(btn_x) then
    game.update=game_update
    game.draw=game_draw
  end
end

function menu_draw()
  cls()
  print("press ❎ to play", 60, 60)
end
-->8
--game
--the main game
function game_update()
 background_update()
 player_update()
 player_animate() 
 cam_update()
end

function game_draw()
  cls()
  map(0,32)
  map(0,0)
  print(p.state, 5,5)
  spr(p.sp,p.x,p.y,1,1,p.flp,false)
end
-->8
--collide

-- collide_map
-- check if there is a collision between an object and a sprite
-- obj: table x,y,w,h
-- aim: direction,left,right,up,down
-- flag: sprite flag type
function collide_map(obj,aim,flag)
  
  local x=obj.x  local y=obj.y
  local w=obj.w  local h=obj.h
  
  local x1=0  local y1=0
  local x2=0  local y2=0
  
  if aim=="left" then
    x1=x-1  y1=y
    x2=x    y2=y+h-1
    
  elseif aim=="right" then
    x1=x+w-1  y1=y
    x2=x+w    y2=y+h-1
    
  elseif aim=="up" then
    x1=x+2    y1=y-1
    x2=x+w-3  y2=y
    
  elseif aim=="down" then
    x1=x+2    y1=y+h
    x2=x+w-3  y2=y+h
  end
  x1/=8  y1/=8
  x2/=8  y2/=8
  
  if fget(mget(x1,y1),flag) 
  or fget(mget(x1,y2),flag) 
  or fget(mget(x2,y1),flag) 
  or fget(mget(x2,y2),flag) then
    return true
  end
  
  return false 
end
-->8
--player

function player_update()

  --physics
  p.dy+=gravity
  p.dx*=friction
  
  if btn(btn_left) then
    p.dx-=p.acc_x
    p.flp=true
  end
  if btn(btn_right) then
    p.dx+=p.acc_x
    p.flp=false
  end
  
  --todo revisit this
  --and add variable jumping
  if btnp(btn_x)
  and p.state!="jumping" 
  and p.state!="falling" then
    p.dy-=p.acc_y
  end
  
  --check y direction
  if p.dy>0 then
    p.state="falling"
    
    --limit speed
    p.dy=mid(-p.max_dy, p.dy, p.max_dy)
    
    if collide_map(p,"down",0) then
      if btn(btn_left)
      or btn(btn_right) then
        p.state="running"
      else
        p.state="idle"
      end
      p.dy=0
      p.y-=((p.y+p.h+1)%8)-1
    end
  elseif p.dy<0 then
    p.state="jumping"
    if collide_map(p,"up",0) then
      p.dy=0
    end
  end

  --check x direction  
  if p.dx<0 then
    
    --limit player to max speed
    p.dx=mid(-p.max_dx, p.dx, p.max_dx)
    
    if collide_map(p,"left",0) then
      p.dx=0
    end
  elseif p.dx>0 then
    --limit player to max speed
    p.dx=mid(-p.max_dx, p.dx, p.max_dx)
  
    if collide_map(p,"right",0) then
      p.dx=0
    end
  end  
 
  p.x+=p.dx
  p.y+=p.dy
  
  --limit to map
  if p.x<map_start then
    p.x=map_start
  end
  if p.x>map_end-p.w then
    p.x=map_end-p.w
  end 
  
end

function player_animate()
  if p.state=="jumping" then
   p.sp=6
  elseif p.state=="running" then
    if time()-p.anim>.1 then
      p.anim=time()
      p.sp+=1
      if p.sp>5 then
        p.sp=2
      end
    end
  else --player idle
      p.sp=3
  end
end
-->8
--camera
function cam_update()
  
  --camera follows player
  cam_x=p.x-64+(p.w/2)
  if cam_x<map_start then
    cam_x=map_start
  end
  --end a gamescreen early from end
  if cam_x>map_end-128 then
    cam_x=map_end-128
  end
  camera(cam_x,0)
end
-->8
--backgroud

star_x-=
star_spd=0.5


function background_update()
   star_x-=star_spd
   if map_x<-127 then map_x=0 end
   
end

function background_draw()
  map(0,32,map_x+128,0,16,16)
end
__gfx__
00000000000bbb0000000bb000000bb000000bb000000bb00000bb00000000000000000000000000000000000000000000000000000000000000000000000000
00000000002bbcb00002bbcb0002bbcb0002bbcb0002bbcb002bbcb0000000000000000000000000000000000000000000000000000000000000000000000000
00700700000bbbb00000bbbb0000bbbb0000bbbb0000bbbb000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000
00077000002bbb000002bbb00002bbb00002bbb00002bbb0002bbb00000000000000000000000000000000000000000000000000000000000000000000000000
00077000000bb0000b00bb000b00bb000b00bb000b00bb00000bb000000000000000000000000000000000000000000000000000000000000000000000000000
007007000b0bbb0000bbbbb000bbbbb000bbbbb000bbbbb0000bbb00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb000000bb000000bb000000bb000000b330000bbb0b0000000000000000000000000000000000000000000000000000000000000000000000000
000000000003bb000003bb000030bb00000bb30000b003300b000b00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ed000000aaa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00deee0000aaa9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddeedd00aaa9a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeed00999aa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eedeee009aaa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0deddee009aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00deee0009a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00669900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00669900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00669900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddd00dddddddddddddddddddddddd00dddddddddddd0000000000dddddddd00000000000000000000000000000000000000000000000000000000
070000000dddddd0dd55d5dddddddddddddddddd0dddddddddddddd000000000d666666100000000000000000000000000000000000000000000000000000000
00000000ddddddddddd5565dd5ddd5dd55ddddddddd5dd5ddd55dddd00000000d666666100000000000000000000000000000000000000000000000000000000
00000000dddddddd55d56665565dd6d55ddd5dd5dd555d655d5dd5dd00000000d666666100000000000000000000000000000000000000000000000000000000
000000005dd5d55d665666d6666556566dd555d6d56665626566d65d00000000d666666100000000000000000000000000000000000000000000000000000000
000000000dd65c5d6266655d6626666665d66656566e6666c66e566500000000d666666100000000000000000000000000000000000000000000000000000000
000000000556665566666655566655666c56e66666666c666666662600000000d666666100000000000000000000000000000000000000000000000000000000
00000000066e66606e666666666e66c666666666c66666666e66666600000000d111111100000000000000000000000000000000000000000000000000000000
000000000626666000000000666666666666666c6666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006666c60000000006666676662666666c666266c00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c666660000000006c6667766666c666666666e600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066e6660000000006667766666666d56e66c666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666d000000000666676e65666d5666666666200000000000000000000000000000000000000000000000000000000000000000000000000000000
000009000666666000000000626666655d6e666626e6006600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002666660000000006666e6665d6662660666606000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006666c60000000006666666c666666660060600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005000000000000000000000500000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000400000000040005000000040000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006000000000600000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000000005000000000000000004000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000000000040000060000000005000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004000005000000000000000000000000000000040000040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000400000000050000050000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000500000005000000000000000006060004000006000000000000060000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004000000000006000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050006000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000040000060000000000040000040000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004000005000000000000000005000600000000000000000500000400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600050000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000002000000000660565000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000022000000000606650000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000228000000000006660000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002288000000000000600000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022888000000000006560000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00228888000000000060506000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888000000000600500600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000588000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001151000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101000100000000000000000100010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005300420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005300420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005300420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004800484848480000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000005100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424242424242424242424242424242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5252525252525252525252525252525252525252525252525252525252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0105010017252182521725216252142521325214252172521e2522225224252212521e2521a252152521125213252162521a25220252252522925229252282522725225252222522125200202002020020200202
003000202773427724227341d744187241b74422724247241b72422724247141f724247342771429724247342772427724227141d714187241b73422724247241f7342272424724277241f734277342973426734
011800200005003050000500705007050070200000000000000500305000050070500705007020070000000000050030500005008050080500802000000000000005003050000500805008050080200c04007020
011800200c0530c0530c0233f003246150000000000246150c06300000000000c0630c0630c02324600246150c0530c0330c0630c0532461500000000000c05300000000000c053180430c053180002461524615
010d00000070002700017000070001700017000270002700037000370003700047000470005700057000570005700057000470003700037000370002700017000070001700027000270003700027000270001700
__music__
02 02010344

