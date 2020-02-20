extends StaticBody2D

var PositionsImage = Image.new()
var PositionsTex = ImageTexture.new()

var number_of_holes = 0

var ore_types = [load("res://Asteroids/Ore/Iron Ore.tscn")]
var ore_positions = []
var min_ore_distance = 85

func _ready():
	PositionsImage.create(1, 100, false, 15)
	
	var spawn_radius = $Sprite.texture.get_size().x/2 - 60
	
	for i in range (global.random_number(2, 9)):
		var ore = ore_types[global.random_number(0, len(ore_types))] # It isn't len(ore_types) - 1 because the max number in the random_number method is excluded
		var ore_instance = ore.instance()
		
		var pos
		var get_new_pos = true
		while get_new_pos:
			var pos_x = global.random_number(-spawn_radius, spawn_radius)
			var pos_y = global.random_number(-spawn_radius, spawn_radius)
			pos = Vector2(pos_x, pos_y)
			
			get_new_pos = false
			if pos.length() > spawn_radius:
				get_new_pos = true
			
			for posit in ore_positions:
				if pos.distance_to(posit) < min_ore_distance:
					get_new_pos = true
		
		ore_positions.append(pos)
		ore_instance.position = pos
		
		$Ore.add_child(ore_instance) # The ore node has the outline shader.
		ore_instance.set_owner($Ore)

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

func _on_Rocket_Click_Detection_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if get_tree().change_scene("res://Space/Spawned Space Scene.tscn") != OK:
			print_debug("An error occured while switching scene.")
