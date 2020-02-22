extends KinematicBody2D

const rotation_amount = 3
const acc = 10
const deacc = 5
const fire_particles_lifetime = 1
const terminal_velocity = 500
const max_health = 100
const max_fuel = 400

var velocity = Vector2()

var health
var fuel
var can_hurt = true

func _ready():
	$CPUParticles2D.emitting = false
	
	$"Health Bar".max_value = max_health
	health = max_health
	
	$"Rocket HUD/Fuel Bar".max_value = max_fuel
	fuel = max_fuel

func _process(_delta):
	if health < max_health:
		$"Health Bar".visible = true
	
	$"Rocket HUD/Fuel Bar".value = fuel

func _physics_process(delta):
	input()
	movement(delta)

func input():
	if Input.is_action_pressed("thrust") and fuel > 0:
		velocity += Vector2(0, -acc).rotated(rotation)
		$CPUParticles2D.emitting = true
		fuel -= 1
	
	if Input.is_action_pressed("thrust_back") and fuel > 0:
		velocity -= Vector2(0, -acc).rotated(rotation)
		fuel -= 1
	
	if Input.is_action_pressed("turn_right"):
		rotate(deg2rad(rotation_amount))
	
	if Input.is_action_pressed("turn_left"):
		rotate(deg2rad(-rotation_amount))
	
	if Input.is_action_just_pressed("land") and $"Landing RayCast2D".is_colliding():
		land($"Landing RayCast2D".get_collider())

func movement(_delta):
	velocity *= 0.997
	
	if velocity.length() > terminal_velocity:
		velocity = velocity.normalized() * terminal_velocity
	
	velocity = move_and_slide(velocity)
	
	if get_slide_count() > 0 and can_hurt:
		hurt(velocity.length()/10)

func hurt(dmg):
	var old_health = health
	
	health -= dmg
	health = max(health, 0)
	
	$"Health Bar Tween".interpolate_property($"Health Bar", "value", old_health, health, 0.5)
	$"Health Bar Tween".start()
	
	if (health <= 0):
		die()
	
	can_hurt = false
	$"Damage Shield".start()

func _on_Damage_Shield_timeout():
	can_hurt = true

func die():
	queue_free()

func land(landing_asteroid):
	get_parent().save_game()
	
	if not global.ore_positions.has(landing_asteroid.position):
		global.ore_positions[landing_asteroid.position] = []
	
	if not global.hole_positions.has(landing_asteroid.position):
		global.hole_positions[landing_asteroid.position] = []
	
	global.recent_landing_asteroid_pos = landing_asteroid.position
	
	if get_tree().change_scene("res://Asteroids/Asteroid Scene.tscn") != OK:
		print_debug("An error occured while switching scene.")
