extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var bullet = preload("res://scenes/bullet.tscn")
var is_shooting: bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# ELIMINADO: look_at(get_last_motion()) ya no es necesario aquí
	
	if Input.is_action_just_pressed("shoot"):
		is_shooting = true
		anim.play("shoot")
		shoot()
		
		await anim.animation_finished
		is_shooting = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	actualizar_animaciones(direction)

	move_and_slide()
	
func shoot():
	var newBullet = bullet.instantiate()
	
	if anim.flip_h:
		newBullet.direction_bullet = PI
		
		newBullet.global_position = global_position + Vector2(-abs($bulletspawn.position.x), $bulletspawn.position.y)
	else:
		newBullet.direction_bullet = 0.0 # Derecha
		newBullet.global_position = $bulletspawn.global_position
		
	get_parent().add_child(newBullet)
	
func actualizar_animaciones(direction: float) -> void:
	if is_shooting:
		return
	if not is_on_floor():
		anim.play("jump")
	else:
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")
