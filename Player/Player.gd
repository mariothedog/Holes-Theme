extends KinematicBody2D

const gravity_strength = 800
const jump_vec = Vector2(0, 500)

onready var asteroid = get_parent().get_node("Asteroid Object")

var acc = Vector2(15, 0)

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
	
	if $RayCast2D.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D3.is_colliding():
		velocity *= 0.9 # Ground Friction
		acc = Vector2(15, 0)
	else:
		velocity += gravity * delta
		velocity *= 0.99 # Space Friction
		acc = Vector2(6, 0)
	
	if jump and ($RayCast2D.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D3.is_colliding()):#is_on_floor():
		velocity = jump_vec.rotated(position.direction_to(asteroid.position).angle() + PI/2)
	
	velocity = move_and_slide(velocity, -position.direction_to(asteroid.position))
	
	rotation = direction_to_asteroid.angle() - PI/2

func animate():
	var right_vec = acc.rotated(position.direction_to(asteroid.position).angle() - PI/2)
	var angle = rad2deg(velocity.angle_to(right_vec))
	if angle < 20 and angle >= 0:
		$AnimatedSprite.flip_h = false
	
	if angle > 160 and angle <= 180:
		$AnimatedSprite.flip_h = true
	
	if velocity.length() > 50:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()

func _on_Asteroid_Object_update_inventory():
	$HUD.update_inventory()
