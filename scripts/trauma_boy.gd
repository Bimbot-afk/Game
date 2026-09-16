extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
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

func actualizar_animaciones(direction: float) -> void:
	if not is_on_floor():
		anim.play("jump")
	else:
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")
