name_en = "PC"
name_es = "PC"
name_fr = "PC"
name_ch = "PC"

material_guid = '98c05714-bf4e-4455-ba27-57d74fe331e4'

bed_temp_degree_c = 110

-- affecting settings to each extruder
for i = 0, extruder_count-1, 1 do
  _G['extruder_temp_degree_c_'..i] = 290
  _G['filament_priming_mm_'..i] = 8.0
  _G['priming_mm_per_sec_'..i] = 40
  _G['retract_mm_per_sec_'..i] = 40
end

-- affecting settings to all brushes
for i = 0, max_number_brushes, 1 do
	_G['flow_multiplier_'..i] = 1.0
	_G['speed_multiplier_'..i] = 1.0
end

enable_fan = false
fan_speed_percent = 10
fan_speed_percent_on_bridges = 80
