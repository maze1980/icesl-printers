name_en = "Fast print"
name_fr = "Impression rapide"
name_es = "Impresión rápida"

z_layer_height_mm = 0.3

print_speed_mm_per_sec = 70
first_layer_print_speed_mm_per_sec = 20
perimeter_print_speed_mm_per_sec = 50
cover_print_speed_mm_per_sec = 50

travel_speed_mm_per_sec = 180

-- affecting settings to all brushes
for i = 0, max_number_brushes, 1 do
  _G['print_perimeter_'..i] = true
  _G['num_shells_' ..i] = 1
  _G['cover_thickness_mm_'..i] = 1.2
  _G['infill_percentage_'..i] = 20
end