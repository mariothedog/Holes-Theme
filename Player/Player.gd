extends KinematicBody2D

const gravity_strength = 800
const jump_vec = Vector2(0, 500)

onready var asteroid = get_parent().get_node("Asteroid Object")

var acc = Vector2(10, 0)

var velocity = Vector2()

var jump = false

func _physics_process(delta):
	input()
	movement(delta)
	animate()

func input():
	if Input.is_action_pressed("turn_right"):
		# The direction that the player travels is the tangent of the asteroid (Perpendicular to the radius)
		velocity += acc.rotated(position.direction_to(asteroid.position).angle() - PI/2)
	
	if Input.is_action_pressed("turn_left"):
		velocity -= acc.rotated(position.direction_to(asteroid.position).angle() - PI/2)
	
	jump = false
	if Input.is_action_just_pressed("thrust"):
		jump = true

func movement(delta):
	var direction_to_asteroid = position.direction_to(asteroid.position)
	
	var gravity = direction_to_asteroid * gravity_strength
	
	velocity += gravity * delta
	
	if is_on_floor():
		velocity *= 0.95 # Ground Friction
		acc = Vector2(10, 0)
	else:
		velocity *= 0.99 # Space Friction
		acc = Vector2(6, 0)
	
	if jump and is_on_floor():
		velocity = jump_vec.rotated(position.direction_to(asteroid.position).angle() + PI/2)
	
	velocity = move_and_slide(velocity, -position.direction_to(asteroid.position))
	
	rotation = direction_to_asteroid.angle() - PI/2

func animate():
	pass
