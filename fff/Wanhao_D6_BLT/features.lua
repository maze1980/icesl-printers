--Wanhao Duplicator 6
--features.lua
--30.11.2018 maze1980
--12.01.2024 maze1980


--custom variables
fan_speed = 255
first_layer_fan_speed = 0

bed_size_x_mm = 200
bed_size_y_mm = 200
bed_size_z_mm = 185

extruder_count = 1
nozzle_diameter_mm = 0.4
filament_diameter_mm = 1.75

max_number_extruders = 1
z_layer_height_mm_min = 0.1
z_layer_height_mm_max = nozzle_diameter_mm * 0.75
filament_priming_mm = 3.0
priming_mm_per_sec = 40
retract_mm_per_sec = 40
extruder_temp_degree_c = 190
extruder_temp_degree_c_min = 150
extruder_temp_degree_c_max = 250
extruder_mix_count = 1
-- print speeds
first_layer_print_speed_mm_per_sec = 20
first_layer_print_speed_mm_per_sec_min = 5
first_layer_print_speed_mm_per_sec_max = 80

perimeter_print_speed_mm_per_sec = 20
perimeter_print_speed_mm_per_sec_min = 5
perimeter_print_speed_mm_per_sec_max = 80

print_speed_mm_per_sec_min = 5
print_speed_mm_per_sec_max = 80

-- bed temperatures
bed_temp_degree_c = 50
bed_temp_degree_c_min = 0
bed_temp_degree_c_max = 120


for i = 0, max_number_extruders, 1 do
  _G['nozzle_diameter_mm_'..i] = nozzle_diameter_mm
  _G['filament_diameter_mm_'..i] = filament_diameter_mm
  _G['filament_priming_mm_'..i] = filament_priming_mm
  _G['priming_mm_per_sec_'..i] = priming_mm_per_sec
  _G['retract_mm_per_sec_'..i] = retract_mm_per_sec
  _G['extruder_temp_degree_c_' ..i] = extruder_temp_degree_c
  _G['extruder_temp_degree_c_'..i..'_min'] = extruder_temp_degree_c_min
  _G['extruder_temp_degree_c_'..i..'_max'] = extruder_temp_degree_c_max
  _G['extruder_mix_count_'..i] = 1
end

-- Add a few checkboxes
add_checkbox_setting('custom_raft_creation', 'Raft (custom)', 'Prints a raft as defined in the printer profile')
add_checkbox_setting('custom_bltouch_calibration', 'Calibrate bed mesh (BL-Touch)', 'Measures the bed before starting the print')
custom_raft_creation = false
custom_bltouch_calibration = true

add_setting('custom_increase_distance', 'Z-offest (0.0..0.4)', 0, 0.4, 'Adds an extra offset for the first layer')
add_setting('custom_Kp', 'Kp', -999, 999, 'PID setting (expert)')
add_setting('custom_Ki', 'Ki', -999, 999, 'PID setting (expert)')
add_setting('custom_Kd', 'Kd', -999, 999, 'PID setting (expert)')
custom_increase_distance = 0.0
custom_Kp =  9.12 --factory default setting
custom_Ki =  0.41 --factory default setting
custom_Kd = 50.98 --factory default setting