--Wanhao Duplicator 6 with BLtouch
--29.12.2018 maze1980
--12.01.2024 maze1980

--global variables
current_z = -1         -- The current z height
current_frate = -1     -- The current extruder feed rate
current_fanspeed = -1  -- The current fan speed
current_extruder = -1  -- The current extruder

function comment(text)
  output('; ' .. text)
end

function select_extruder(extruder)
  output('; select_extruder' .. extruder)
  current_extruder = extruder
end

function swap_extruder(from,to,x,y,z)
  output('; swap_extruder to' .. to)
  current_extruder = to
end

-- IceSL required function, called when setting the extruder temperature
function set_extruder_temperature(extruder,temperature)
  output('M104 T' .. extruder .. ' S' .. f(temperature))
end

-- IceSL required function, eventually called when enable_min_layer_time is used
function wait(sec,x,y,z)
  output("G4 S" .. sec .. "; Wait for " .. sec .. "s")
end

--code
function header()
  output(';(**** Wanhao Duplicator 6 with BL-Touch ****)')
  output(';Print time [s]...: ' .. time_sec)
  output(';Filament [mm]....: ' .. filament_tot_length_mm[0])
  output(';Print size X [mm]: ' .. f(min_corner_x+extent_x))
  output(';Print size Y [mm]: ' .. f(min_corner_y+extent_y))
  output(';Print size Z [mm]: ' .. f(extent_z))
  output(';(**** startup gcode ****)')
  output(';(**** home axes ****)')
  output('M117 Homing...')               -- set LCD message
  output('M355 S0')                      -- lights off
  output('G21')                          -- set units to mm
  output('G90')                          -- set positioning to absolute
  output('M82')                          -- set extruder to absolute
  output('M106 S0')                      -- disable the cooling fan
  output('G1 F' .. 60 * travel_speed_mm_per_sec) --set the travel speed
  output('G28 X0 Y0')                    -- move X and Y to min endstops
  output('G0 X69 Y120')                  -- center the probe (Offset of BLtouch: x=100-31, y=100+20)
  output('G28 Z0')                       -- move Z to min endstops (BLtouch)
  if custom_bltouch_calibration then
    output('G29')                        -- perform auto-leveling if requested (BLtouch)
  end
  output('G28 X0 Y0')                    -- move X and Y to min endstops
  if custom_increase_distance>0 then
    output('G1 Z' .. f(15.0 + custom_increase_distance)) -- move z to (15.0 + custom_increase_distance)
    output('G92 Z15.0')                  -- define current z as 15.0
  end
  output(';(**** heating ****)')
  output('M117 Heating up...')            -- set LCD message
  output('M301 P' .. f(custom_Kp) .. ' I' .. f(custom_Ki) .. ' D' .. f(custom_Kd)) --set Kp, Ki and Kd (typ. unique per material)
  output('G1 Z15.0')                            -- move the platform to 15mm
  output('M190 S' .. bed_temp_degree_c)         -- set and wait for HBP temp
  output('M109 S' .. extruder_temp_degree_c[0]) -- set and wait for extruder temp
  output(';(**** priming ****)')
  output('M117 Priming...')              -- set LCD message
  output('G1 F' .. 60 * first_layer_print_speed_mm_per_sec) --set the 1st layer speed
  output('G92 E0')                       -- zero extrusion length
  output('G1 X0 Y0 Z1')                  -- move close to the board
  output('G1 X100 Y0 Z0.2 E4')           -- extrude a line in the front, from (0,   0, 1.0) to (0, 100, 0.2)
  output('G1 X190 Y0 Z0.2 E8')           -- extrude a line in the front, from (0, 100, 0.2) to (0, 190, 0.2)
  output('G92 E0')                       -- zero extrusion length
  output('M117 Printing...')             -- set LCD message
  output(';(**** end of end of print gcode ****)')
  if custom_raft_creation then 
    output('; raft start')
    custom_raft()
    output('; raft end')
  end
end

function footer()
  output(';(**** finish gcode ****)')
  output('M140 S0')                      -- set HBP temp
  output('M104 S0')                      -- set extruder temp
  output('G91')                          -- set positioning to relative
  output('M83')                          -- set extruder to relative
  output('G1 E-1.0 F600')                -- retract 0.1mm
  output('G1 Z1 E-5.0 F600')             -- retract 0.4mm and lift nozzle
  output('G1 Z50 ')                      -- lift nozzle 50mm
  output('M84')                          -- steppers off
  output('G90')                          -- set positioning to absolute
  output('M82')                          -- set extruder to absolute
  output('M106 S0')                      -- disable the cooling fan
  output('M117 ...done.')                -- output text
  output(';(**** end of finish gcode ****)')
end

function layer_start(z)
  output(';(**** layer ' .. layer_id .. ' start ****)')
  output('G1 Z' .. f(z) .. ' F3000')
  current_z = z
end

function layer_stop()
  output(';(**** layer ' .. layer_id .. ' complete ****)')
end

function retract(extruder,e)
  local speed = retract_mm_per_sec[extruder] * 60;
  local e_new = e - filament_priming_mm[extruder]
  output('G1 F' .. speed .. ' E' .. ff(e_new) .. ' ; ')
  return e_new
end

function prime(extruder,e)
  local speed = priming_mm_per_sec[extruder] * 60
  local e_new = e + filament_priming_mm[extruder]
  output('G1 F' .. speed .. ' E' .. ff(e_new) .. ' ; ')
  return e_new
end

function move_xyz(x,y,z)
  if (z == current_z) then
    output('G1 X' .. f(x) .. ' Y' .. f(y) )
  else
    output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z))
    current_z = z
  end
end

function move_xyze(x,y,z,e)
  if (z == current_z) then
    output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' E' .. ff(e))
  else
    output('G1 X' .. f(x) .. ' Y' .. f(y) .. ' Z' .. f(z+z_offset) .. ' E' .. ff(e))
    current_z = z
  end
end

function move_e(e)
  --never called, as far as I know
  output('G1 E' .. ff(e))
end

function set_feedrate(feedrate)
  if feedrate ~= current_frate then
    output('G1 F' .. feedrate)
    current_frate = feedrate
  end
end

function extruder_start()
  --not implemented (only Teacup/RepRap)
  --output('M101')
end

function extruder_stop()
  --not implemented (only Teacup/RepRap)
  --output('M103')
end

function progress(percent)
  output('M73 P' .. percent)
end

function set_fan_speed(fanspeed)
  if fanspeed ~= current_fanspeed then
    output('M106 S'.. math.floor(255 * fanspeed/100))
    current_fanspeed = fanspeed
  end
end


function custom_raft()
  output(';(**** custom raft start ****)')
  --custom variables, customizable
  raft_fan_speed = 255              --print 2nd, 3rd and 4th layer of raft with fan
  raft_cooldown_sec = 120           --wait xx seconds after raft
  raft_distance_to_object_mm = 0.1  --start the object with extra space above the raft
  
  --derived input variables
  height1  = nozzle_diameter_mm * 3/4 --0.3mm for 0.4mm nozzle
  spacing1 = nozzle_diameter_mm * 5   --2.0mm for 0.4mm nozzle
  height2  = nozzle_diameter_mm * 2/4 --0.2mm for 0.4mm nozzle
  spacing2 = nozzle_diameter_mm       --0.4mm for 0.4mm nozzle
  center_x = bed_size_x_mm / 2
  center_y = bed_size_y_mm / 2

  output("; height1= "..f(height1))
  output("; spacing1="..f(spacing1))
  output("; height2= "..f(height2))
  output("; spacing2="..f(spacing2))
  output("; center_x="..f(center_x))
  output("; center_y="..f(center_y))

  --other variables
  --dx, dy
  --e1, e2, e1.., e2..
  dx = extent_x + 4 * spacing1 - (extent_x % (2 * spacing1))
  dy = extent_y + 4 * spacing1 - (extent_y % (2 * spacing1))
  if dx>bed_size_x_mm then dx=bed_size_x_mm end
  if dy>bed_size_y_mm then dy=bed_size_y_mm end
  dxh=dx/2
  dyh=dy/2
  output("; min_corner_x="..f(min_corner_x))
  output("; min_corner_y="..f(min_corner_y))
  output("; extent_x="..f(extent_x))
  output("; extent_y="..f(extent_y))
  output("; max_x="..f(min_corner_x+extent_x))
  output("; max_y="..f(min_corner_y+extent_y))
  output("; dx="..f(dx))
  output("; dy="..f(dy))

  --calculate the extrusion length for 1mm length with height 1/1 and 1/2 nozzle dia meter
  --V = pi*r*r*h
  --h = V/pi*r*r //h=filament push, r=r filament, V=f(line length)
  --h = (nozzle_diameter/2)^2 * math.pi * length / pi*r^2
  --e = (nozzle_diameter/2)^2 * length / r^2
  --debug
  e1 = (nozzle_diameter_mm/2)^2/(filament_diameter_mm_0/2)^2 --0.04/0.77=0.0522
  e2 = e1/2                                                  --          0.0026
  output("; e1="..f(e1))
  output("; e2="..f(e2))

  --real
  e1xl = dx *       (nozzle_diameter_mm/2)^2/(filament_diameter_mm_0/2)^2
  e1xs = spacing1 * (nozzle_diameter_mm/2)^2/(filament_diameter_mm_0/2)^2
  e2xl = e1xl
  e2xs = e1xs/10
  e1yl = dy *       (nozzle_diameter_mm/2)^2/(filament_diameter_mm_0/2)^2
  e1ys = spacing1 * (nozzle_diameter_mm/2)^2/(filament_diameter_mm_0/2)^2
  e2yl = e1yl
  e2ys = e1ys/10
  output("; e1xl="..f(e1xl))
  output("; e1xs="..f(e1xs))
  output("; e1yl="..f(e1yl))
  output("; e1ys="..f(e1ys))
  output("; e2xl="..f(e2xl))
  output("; e2xs="..f(e2xs))
  output("; e2yl="..f(e2yl))
  output("; e2ys="..f(e2ys))
  --make the raft
  e = 0
  z = 0

  --make the raft, first layer, big spacing
  output("; -1-")
  set_feedrate(60*first_layer_print_speed_mm_per_sec)
  z = z + height1
  
  retract(current_extruder,e)
  move_xyz (center_x - dxh, center_x - dyh, z)              --start pos
  prime(0,e)
  e = e + e1yl
  move_xyze(center_x - dxh, center_x + dyh, z, e)           --first long y
  for x=-dxh, dxh-spacing1, 2*spacing1 do
    e = e + e1xs
    move_xyze(center_x + x+  spacing1, center_x + dyh, z, e) --short x
    e = e + e1yl
    move_xyze(center_x + x+  spacing1, center_x - dyh, z, e) --long y
    e = e + e1xs
    move_xyze(center_x + x+2*spacing1, center_x - dyh, z, e) --short x
    e = e + e1yl
    move_xyze(center_x + x+2*spacing1, center_x + dyh, z, e) --long y
  end

  --make the raft, second layer, big spacing
  output("; -2-")
  set_feedrate(60*support_print_speed_mm_per_sec)
  temp_fanspeed = current_fanspeed
  set_fan_speed(raft_fan_speed) --cool the raft
  z = z + height1
  move_xyz (center_x + dxh, center_x + dyh, z)  
  move_xyze(center_x - dxh, center_x + dyh, z, e)           --first long x
  for y=dyh, -dyh+spacing1, -2*spacing1 do
    e = e + e1ys
    move_xyze(center_x - dxh, center_x + y - spacing1, z, e) --short y
    e = e + e1xl
    move_xyze(center_x + dxh, center_x + y - spacing1, z, e) --long x
    e = e + e1ys
    move_xyze(center_x + dxh, center_x + y - 2*spacing1, z, e) --short y
    e = e + e1xl
    move_xyze(center_x - dxh, center_x + y - 2*spacing1, z, e) --long x
  end

  --make the raft, third layer, small spacing
  output("; -3-")
  z = z + height2
  move_xyz (center_x - dxh, center_x - dyh, z)  
  move_xyze(center_x - dxh, center_x + dyh, z, e)           --first long y
  for x=-dxh, dxh-spacing2, 2*spacing2 do
    e = e + e1xs
    move_xyze(center_x + x + spacing2, center_x + dyh, z, e) --short x
    e = e + e1yl
    move_xyze(center_x + x+  spacing2, center_x - dyh, z, e) --long y
    e = e + e1xs
    move_xyze(center_x + x+2*spacing2, center_x - dyh, z, e) --short x
    e = e + e1yl
    move_xyze(center_x + x+2*spacing2, center_x + dyh, z, e) --long y
  end

  --make the raft, fourth layer, small spacing
  output("; -4-")
  z = z + height2
  move_xyz (center_x + dxh, center_x + dyh, z)  
  move_xyze(center_x - dxh, center_x + dyh, z, e)           --first long x
  for y=dyh, -dyh+spacing2, -2*spacing2 do
    e = e + e2ys
    move_xyze(center_x - dxh, center_x + y - spacing2, z, e) --short y
    e = e + e2xl
    move_xyze(center_x + dxh, center_x + y - spacing2, z, e) --long x
    e = e + e2ys
    move_xyze(center_x + dxh, center_x + y - 2*spacing2, z, e) --short y
    e = e + e2xl
    move_xyze(center_x - dxh, center_x + y - 2*spacing2, z, e) --long x
  end

  output('; cooldown')
  --cooldown
  if raft_cooldown_sec>0 then

    --idle turns
    move_xyz(0, 0, z + 10)
    output('G4 S'..f(raft_cooldown_sec))
    move_xyz(center_x - dxh, center_x - dyh, z)
    
    --prime after cooldown
    output('; prime after cooldown')
    z_prime = z+height2
    move_xyz(center_x - dxh, center_x - dyh, z_prime)
    e = e + e2yl*0.9
    move_xyze(center_x - dxh, center_x + dyh, z_prime, e)
    e = e + e2xl*0.9
    move_xyze(center_x + dxh, center_x + dyh, z_prime, e)
    e = e + e2yl*0.9
    move_xyze(center_x + dxh, center_x - dyh, z_prime, e)
    e = e + e2xl*0.9
    move_xyze(center_x - dxh, center_x - dyh, z_prime, e)

    output('; prepare for object')
    --move nozzle on top of raft
    move_xyz(center_x - dxh + spacing1, center_x - dyh + spacing1, z_prime)
    z = z + raft_distance_to_object_mm
    move_xyz(center_x - dxh + spacing1,center_x - dyh + spacing1, z)
    output('G92 Z0') -- zero z
    output('G92 E0') -- zero extrusion length
    set_fan_speed(temp_fanspeed) --restore original fan speed
  end
  output(';(**** custom raft end ****)')
end
