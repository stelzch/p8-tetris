pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- simple tetris clone
-- author: ch-st.de

pieces={
{{1,0},
 {1,1},
 {1,0}},

{{1,1},
 {1,1}},

{{1,1,1,1}},

{{1,1},
 {1,0},
 {1,0}},
 
{{1,0},
 {1,1},
 {0,1}},
}

block_size = 5 -- pixels
field = {}
field_width = 10 -- in blocks
field_height = 20 -- in blocks

current_piece = nil
current_x = nil -- can range from 1 to field_width (inclusive)
current_y = nil -- can range from 1 to field_height (inclusive)

speed = 1 / 5 -- blocks per second
progress = 0.0
debug_msg = ""


function copy_array_2d(src)
  target = {}
  for y=1,#src do
    add(target, {})
    for x=1,#src[1] do
      add(target[y],
              src[y][x])
    end
  end
  return target
end

function rotate_array_2d(src)
  target = {}
  -- transpose it first
  for x=1,#src[1] do
    add(target, {})
    for y=1,#src do
      add(target[x],
        src[y][x])
    end
  end

  -- flip it vertical for
  -- 90 deg rotation
  for y=1,#target do  
  for x=1,#target[1]\2 do
    mirror_x = 
    #target[1] + 1 - x
    target[y][x], target[y][mirror_x] =
    target[y][mirror_x], target[y][x]
  end
  end
  return target
end

function initialize_field()
  for y=1,field_height do
    add(field, {})
    for x=1,field_width do
      add(field[y], 0)      
    end
  end
end

function test_collision(target_x, target_y, array)
  if target_x < 1 or target_y < 1 then
    return true
  end
  for x=1,#array[1] do
    lowest_block = 0
    for y=#array,1,-1 do
      if lowest_block == 0 and array[y][x] > 0 then
        lowest_block = y
      end
    end
    
    if lowest_block != 0 then
      field_x = target_x + x - 1
      field_y = target_y + lowest_block - 1

      if field_x > field_width then
        return true
      end

      if field_y > field_height then
        return true
      end
      
      if field[field_y][field_x] > 0 then
        return true
      end
    end
  end

  return false
end

function spawn_piece()
  current_piece = copy_array_2d(pieces[rnd(#pieces)\1+1])
  current_x = max(1,(field_width - #current_piece[1]) \ 2)
  current_y = 1
end

function _init()
  initialize_field()
  spawn_piece()
  field[field_height][1] = 1
end

function draw_block_array(start_x,start_y,array)
  for y=1,#array do
    for x=1,#array[1] do
      field_val = array[y][x]

      if field_val == 1 then
        screen_x = start_x + (x - 1) * block_size
        screen_y = start_y + (y - 1) * block_size
        spr(0, screen_x, screen_y)
      end
    end
  end

end

function _draw()
  -- draw the field on the screen
  cls()
  start_x = (128 - field_width * block_size) \ 2
  start_y = (128 - field_height * block_size) \ 2

  if field != nil then
    draw_block_array(start_x, start_y, field)
  end


  -- draw the current piece
  if current_piece != nil then
    draw_block_array(start_x + (current_x - 1)* block_size,
        start_y + (current_y - 1) * block_size,
        current_piece)
  end

  print(debug_msg, 0, 0)

end

function eliminate_full_row()
  -- checks whether a full row has appeared that can be eliminated
  -- returns true if a row has been eliminated
  row_number = 0
  for y=1,#field do
    full_row = 1
    for x=1,field_width do
      if field[y][x] == 0 then
        full_row = 0
      end
    end

    if full_row == 1 then
      row_number = y
      break
    end
  end

  -- eliminate row by pulling all rows above it one down
  for y=row_number,1,-1 do
    for x=1,field_width do
      if y == 1 then
        field[y][x] = 0
      else
        field[y][x] = field[y - 1][x]
      end
    end
  end

  return row_number != 0
end

function piece_collision() 
  -- Piece has collided, spawn new one and merge the old one into the field
  for y=1,#current_piece do
    for x=1,#current_piece[1] do
      mx = x + current_x - 1
      my = y + current_y - 1
      if field[my][mx] == 0 then
        field[my][mx] = current_piece[y][x]
      end
    end
  end

  while eliminate_full_row() do
    sfx(1)
  end


  spawn_piece()
end

function _update()
  if current_piece == nil then
    return
  end

  if btnp(2) then
    rotate_piece = rotate_array_2d(current_piece)
    if not test_collision(current_x, current_y, rotate_piece) then
      current_piece = rotate_piece
    end
  elseif btnp(3) then
    while not test_collision(current_x, current_y + 1, current_piece) do
      current_y += 1
    end
    debug_msg = "forward"
    
  elseif btnp(0)
    and not test_collision(current_x - 1, current_y, current_piece) then
    current_x -= 1
  elseif btnp(1)
    and not test_collision(current_x + 1, current_y, current_piece) then
    current_x += 1
  end


  progress += speed
  if progress >= 1 then
    if test_collision(current_x, current_y + 1, current_piece) then
      piece_collision()
    else
      progress = 0
      current_y += 1
    end
  end
  debug_msg = "field has " .. tostr(#field[1])
end


__gfx__
99999000ddddd000eeeee000bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaa4000dccc1000e8882000b5553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaa4000dccc1000e8882000b5553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaa4000dccc1000e8882000b5553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444000d1111000e2222000b3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0400000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050505000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000004050000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000004040505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000005050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000005050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000505050505050504050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012c000e28052280502605023050240502605023050240502605026050240502305021052210502105019750197501975019750197501975019750197501975019750197501d7501275021750127501f7501f750
000300001855024550215501e5501a55016540125400e5400d5500a30005300033000130001200001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000
