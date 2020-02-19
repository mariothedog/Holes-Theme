extends KinematicBody2D

const rotation_amount = 3
const acc = 10
const deacc = 5
const fire_particles_lifetime = 1
const terminal_velocity = 500
const max_health = 100

var velocity = Vector2()

var health
var can_hurt = true

func _ready():
	$CPUParticles2D.emitting = false
	health = max_health

func _process(delta):
	if health < max_health:
		$"Health Bar".visible = true

func _physics_process(delta):
	input()
	movement(delta)
	animate()

func input():
	if Input.is_action_pressed("thrust"):
		velocity += Vector2(0, -acc).rotated(rotation)
		$CPUParticles2D.emitting = true
	
	if Input.is_action_pressed("thrust_back"):
		velocity -= Vector2(0, -acc).rotated(rotation)
	
	if Input.is_action_pressed("turn_right"):
		rotate(deg2rad(rotation_amount))
	
	if Input.is_action_pressed("turn_left"):
		rotate(deg2rad(-rotation_amount))

func movement(_delta):
	velocity *= 0.997
	
	if velocity.length() > terminal_velocity:
		velocity = velocity.normalized() * terminal_velocity
	
	velocity = move_and_slide(velocity)
	
	if get_slide_count() > 0:
		var collision = get_slide_collision(get_slide_count() - 1) # Most recent collision
		
		if $"Landing RayCast2D".is_colliding() and velocity.length() < 300:
			land(collision.collider)
		else:
			if can_hurt:
				hurt(velocity.length()/10)

func animate():
	pass

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

func land(asteroid):
	get_tree().change_scene("res://Asteroids/Asteroid Scene.tscn")
