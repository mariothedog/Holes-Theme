extends Node2D

var spawn_radius = 600
var min_asteroid_dist = 1500
var min_asteroid_dist_to_player = 3000
var max_asteroid_spawn_dist_to_player = 1000

var landing_asteroid_scene = load("res://Asteroids/Landing Asteroid.tscn")

var landing_asteroid_positions = []

func _ready():
	load_game()
	
	randomize()
	
	if len(landing_asteroid_positions) == 0:
		for _i in range(10):
			spawn_asteroid_landing()
	
	save_game()

func _process(_delta):
	var spawnAsteroid = true
	for posit in landing_asteroid_positions:
		if $Rocket.position.distance_to(posit) < min_asteroid_dist_to_player:
			spawnAsteroid = false
			return

	if spawnAsteroid:
		var landing_asteroid_instance = landing_asteroid_scene.instance()

		var pos
		var in_range = true
		while in_range:
			var pos_x = global.random_number($Rocket.position.x - 1700, $Rocket.position.x + 1700)
			var pos_y = global.random_number($Rocket.position.y - 1700, $Rocket.position.y + 1700)
			pos = Vector2(pos_x, pos_y)

			in_range = $Rocket.position.distance_to(pos) < max_asteroid_spawn_dist_to_player

		landing_asteroid_positions.append(pos)
		landing_asteroid_instance.position = pos
		
		add_child(landing_asteroid_instance)

		save_game()

func spawn_asteroid_landing():
	var landing_asteroid_instance = landing_asteroid_scene.instance()
		
	var pos
	var overlapping = true
	while overlapping:
		var pos_x = global.random_number(-4000, 4000)
		var pos_y = global.random_number(-4000, 4000)
		pos = Vector2(pos_x, pos_y)
		
		overlapping = false
		if len(landing_asteroid_positions) > 0:
			for posit in landing_asteroid_positions:
				if pos.distance_to(posit) < min_asteroid_dist or pos.distance_to(Vector2.ZERO) < spawn_radius:
					overlapping = true
	
	landing_asteroid_positions.append(pos)
	landing_asteroid_instance.position = pos
	
	add_child(landing_asteroid_instance)

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE) # "user://savegame.save" is saved at "C:\Users\User\AppData\Roaming\Godot\app_userdata\Holes Theme" on Windows
	
	var landing_asteroid_positions_x = []
	var landing_asteroid_positions_y = []
	for pos in landing_asteroid_positions:
		landing_asteroid_positions_x.append(pos.x)
		landing_asteroid_positions_y.append(pos.y)
	
	var ore_positions = {}
	for asteroid_pos in global.ore_positions.keys():
		var asteroid_pos_split = str(asteroid_pos.x) + "," + str(asteroid_pos.y) # JSON keys have to be a string so they cannot be a list
		ore_positions[asteroid_pos_split] = []
		
		for ore in global.ore_positions[asteroid_pos]:
			var ore_type = ore[0]
			var ore_pos = ore[1]
			ore_positions[asteroid_pos_split].append([ore_type, ore_pos.x, ore_pos.y])
	
	var hole_positions = {}
	for asteroid_pos in global.hole_positions.keys():
		var asteroid_pos_split = str(asteroid_pos.x) + "," + str(asteroid_pos.y) # JSON keys have to be a string so they cannot be a list
		hole_positions[asteroid_pos_split] = []
		
		for hole in global.hole_positions[asteroid_pos]:
			hole_positions[asteroid_pos_split].append([hole.x, hole.y])
	
	var node_data = {
		"landing_asteroid_positions_x" : landing_asteroid_positions_x,
		"landing_asteroid_positions_y" : landing_asteroid_positions_y,
		"rocket_pos_x" : $Rocket.position.x,
		"rocket_pos_y" : $Rocket.position.y,
		"rocket_rot" : $Rocket.rotation,
		"ore_positions" : ore_positions,
		"hole_positions" : hole_positions
	}
	save_game.store_line(to_json(node_data))
	
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		
		var landing_asteroid_positions_x = node_data["landing_asteroid_positions_x"]
		var landing_asteroid_positions_y = node_data["landing_asteroid_positions_y"]
		for i in range(len(landing_asteroid_positions_x)):
			landing_asteroid_positions.append(Vector2(landing_asteroid_positions_x[i], landing_asteroid_positions_y[i]))
		
		for pos in landing_asteroid_positions:
			var landing_asteroid_instance = landing_asteroid_scene.instance()
			
			landing_asteroid_instance.position = pos
			
			add_child(landing_asteroid_instance)
		
		$Rocket.position.x = node_data["rocket_pos_x"]
		$Rocket.position.y = node_data["rocket_pos_y"]
		$Rocket.rotation = node_data["rocket_rot"]
		
		if len(global.ore_positions) == 0:
			var ore_positions = node_data["ore_positions"]
			
			for asteroid_pos in ore_positions.keys():
				var asteroid_pos_split = asteroid_pos.split(",")
				var vec_pos = Vector2(asteroid_pos_split[0], asteroid_pos_split[1])
				global.ore_positions[vec_pos] = []
				
				for ore in ore_positions[asteroid_pos]:
					var ore_type = ore[0]
					var ore_vec_pos = Vector2(ore[1], ore[2])
					global.ore_positions[vec_pos].append([ore_type, ore_vec_pos])
		
		if len(global.hole_positions) == 0:
			var hole_positions = node_data["hole_positions"]
			
			for asteroid_pos in hole_positions.keys():
				var asteroid_pos_split = asteroid_pos.split(",")
				var vec_pos = Vector2(asteroid_pos_split[0], asteroid_pos_split[1])
				global.hole_positions[vec_pos] = []
				
				for hole in hole_positions[asteroid_pos]:
					var hole_vec_pos = Vector2(hole[0], hole[1])
					global.hole_positions[vec_pos].append(hole_vec_pos)
