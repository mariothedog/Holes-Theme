extends Node2D

var spawn_radius = 600
var min_asteroid_dist = 1500
var min_asteroid_dist_to_player = 3000
var max_asteroid_spawn_dist_to_player = 1000

var landing_asteroid_scene = load("res://Asteroids/Landing Asteroid.tscn")

export var landing_asteroid_positions = [] # PackedScenes don't save normal variables so they have to be export variables to be saved.

func _ready():
	if get_tree().current_scene.filename == "res://Space/Space.tscn": # So the asteroids don't get generated again once returning to space.
		var directory = Directory.new() # Temporary until main menu is added
		if directory.file_exists("res://Space/Spawned Space Scene.tscn"):
			get_tree().change_scene("res://Space/Spawned Space Scene.tscn")
		
		randomize()
		
		for _i in range(10):
			spawn_asteroid_landing()
		
		save_scene()

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
			var pos_x = random_number($Rocket.position.x - 1700, $Rocket.position.x + 1700)
			var pos_y = random_number($Rocket.position.y - 1700, $Rocket.position.y + 1700)
			pos = Vector2(pos_x, pos_y)

			in_range = $Rocket.position.distance_to(pos) < max_asteroid_spawn_dist_to_player

		landing_asteroid_positions.append(pos)
		landing_asteroid_instance.position = pos
		add_child(landing_asteroid_instance)
		landing_asteroid_instance.set_owner(self)

		save_scene()

func random_number(mini, maxi):
	return range(mini,maxi)[randi()%range(mini,maxi).size()]

func spawn_asteroid_landing():
	var landing_asteroid_instance = landing_asteroid_scene.instance()
		
	var pos
	var overlapping = true
	while overlapping:
		var pos_x = random_number(-4000, 4000)
		var pos_y = random_number(-4000, 4000)
		pos = Vector2(pos_x, pos_y)
		
		overlapping = false
		if len(landing_asteroid_positions) > 0:
			for posit in landing_asteroid_positions:
				if pos.distance_to(posit) < min_asteroid_dist or pos.distance_to(Vector2.ZERO) < spawn_radius:
					overlapping = true
	
	landing_asteroid_positions.append(pos)
	landing_asteroid_instance.position = pos
	add_child(landing_asteroid_instance)
	landing_asteroid_instance.set_owner(self)

func save_scene():
	var spawned_space_scene = PackedScene.new()
	spawned_space_scene.pack(get_tree().current_scene)
	ResourceSaver.save("res://Space/Spawned Space Scene.tscn", spawned_space_scene)
