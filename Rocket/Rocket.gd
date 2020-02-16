extends KinematicBody2D

const rotation_amount = 3
const acc = 10
const fire_particles_lifetime = 0.3
const terminal_velocity = 400

var velocity = Vector2()

func _ready():
	$CPUParticles2D.emitting = false

func _physics_process(delta):
	input()
	movement(delta)
	animate()

func input():
	if Input.is_action_pressed("thrust"):
		velocity += Vector2(0, -acc).rotated(rotation)
		$CPUParticles2D.emitting = true
		$"Particle Stop Delay".start()
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
			$Tween.interpolate_property($CPUParticles2D, "lifetime", $CPUParticles2D.lifetime, fire_particles_lifetime, 1) # Regrow the fire
			$Tween.start()
	
	if Input.is_action_pressed("brake"):
		velocity -= Vector2(0, -acc).rotated(rotation)
	
	if Input.is_action_pressed("turn_right"):
		rotate(deg2rad(rotation_amount))
	
	if Input.is_action_pressed("turn_left"):
		rotate(deg2rad(-rotation_amount))

func movement(delta):
	velocity *= 0.997
	
	if velocity.length() > terminal_velocity:
		velocity = velocity.normalized() * terminal_velocity
	velocity = move_and_slide(velocity)

func animate():
	pass

func _on_Particle_Stop_Delay_timeout():
	$AnimationPlayer.play("Stop Fire")
	yield($AnimationPlayer, "animation_finished")
	$CPUParticles2D.emitting = false
	$CPUParticles2D.lifetime = fire_particles_lifetime
