extends StaticBody2D

var PositionsImage = Image.new()
var PositionsTex = ImageTexture.new()

var number_of_holes = 0

func _ready():
	PositionsImage.create(1, 100, false, 15)

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
