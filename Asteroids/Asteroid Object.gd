extends StaticBody2D

signal update_inventory

var PositionsImage = Image.new()
var PositionsTex = ImageTexture.new()

var number_of_holes = 0

var ore_types = ["res://Asteroids/Ore/Iron Ore.tscn"]
var min_ore_distance = 120

func _ready():
	PositionsImage.create(1, 100, false, 15)
	
	var ore_positions = global.ore_positions[global.recent_landing_asteroid_pos]
	if len(ore_positions) == 0:
		var spawn_radius = $Sprite.texture.get_size().x/2 - 180
		for _i in range (global.random_number(4, 9)):
			var ore_type = ore_types[global.random_number(0, len(ore_types))] # It isn't len(ore_types) - 1 because the max number in the random_number method is excluded
			var ore_instance = load(ore_type).instance()
			
			var pos
			var get_new_pos = true
			while get_new_pos:
				var pos_x = global.random_number(-spawn_radius, spawn_radius)
				var pos_y = global.random_number(-spawn_radius, spawn_radius)
				pos = Vector2(pos_x, pos_y)
				
				get_new_pos = false
				if pos.length() > spawn_radius:
					get_new_pos = true
				
				for ore in ore_positions:
					if pos.distance_to(ore[1]) < min_ore_distance:
						get_new_pos = true
			
			global.ore_positions[global.recent_landing_asteroid_pos].append([ore_type, pos])
			
			ore_instance.position = pos
			
			ore_instance.connect("input_event", self, "mine_ore", [ore_instance])
			
			$Ore.add_child(ore_instance)
	else:
		for ore in ore_positions:
			var ore_type = ore[0]
			var pos = ore[1]
			
			var ore_instance = load(ore_type).instance()
			
			ore_instance.position = pos
			
			ore_instance.connect("input_event", self, "mine_ore", [ore_instance])
			
			$Ore.add_child(ore_instance)
	
	var hole_positions = global.hole_positions[global.recent_landing_asteroid_pos]
	for hole_pos in hole_positions:
		var pos_x = hole_pos[0]
		var pos_y = hole_pos[1]
		var pos = Vector2(pos_x, pos_y)
		
		make_hole(pos)

func _on_Click_Detection_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		make_hole(get_global_mouse_position())

func make_hole(pos):
	var pos_offsetted = pos + $Sprite.get_rect().size/2
	var uv_pos = pos_offsetted / $Sprite.get_rect().size
	
	PositionsImage.lock()
	PositionsImage.set_pixel(0, number_of_holes,
	Color(uv_pos.x, uv_pos.y, 1, 1))
	# Red stores the x position, Green stores the y position
	
	PositionsImage.unlock()
	
	PositionsTex.create_from_image(PositionsImage) # Shaders only allow textures as Sampler2Ds
	
	$Sprite.material.set_shader_param("hole_positions", PositionsTex)
	$Sprite.material.set_shader_param("number_of_holes", number_of_holes)
	
	number_of_holes += 1
	
	if not pos in global.hole_positions[global.recent_landing_asteroid_pos]: # Without this if statement there would be an infinite loop
		global.hole_positions[global.recent_landing_asteroid_pos].append(pos)
	
	if not $"Mine Iron SFX".playing:
		$"Mine Hole SFX".play()

func _on_Rocket_Click_Detection_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if get_tree().change_scene("res://Space/Space.tscn") != OK:
			print_debug("An error occured while switching scene.")

func mine_ore(_viewport, event, _shape_idx, mined_ore):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		for ore in global.ore_positions[global.recent_landing_asteroid_pos]:
			var ore_pos = ore[1]
			if ore_pos == mined_ore.position:
				global.ore_positions[global.recent_landing_asteroid_pos].erase(ore)
		
		$"Mine Iron SFX".play()
		mined_ore.queue_free()
		
		global.inventory["Iron Ore"] = global.inventory.get("Iron Ore", 0) + global.random_number(2, 6)
		
		emit_signal("update_inventory")
