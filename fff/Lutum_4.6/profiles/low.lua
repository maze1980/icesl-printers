name_en = "Fast print"
name_es = "Impresión rápida"
name_fr = "Impression rapide"

z_layer_height_mm = 2

print_speed_mm_per_sec = 70
perimeter_print_speed_mm_per_sec = 70
cover_print_speed_mm_per_sec = 70
first_layer_print_speed_mm_per_sec = 40
travel_speed_mm_per_sec = 150

-- affecting settings to all brushes
for i = 0, max_number_brushes, 1 do
  _G['num_shells_' ..i] = 1
  _G['print_perimeter_'..i] = true
  _G['cover_thickness_mm_'..i] = 6.0
  _G['infill_percentage_'..i] = 20
end
