extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var col_stand: CollisionShape2D = $CollisionStand
@onready var col_crouch: CollisionShape2D = $CollisionCrouch
@onready var bulletspawn: Node2D = $bulletspawn

var bullet = preload("res://scenes/bullet.tscn")
var is_shooting: bool = false
var is_down: bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	# Estado inicial: de pie
	col_stand.disabled = false
	col_crouch.disabled = true

func _physics_process(delta: float) -> void:
	# 1. Cambiar colisiones al agacharse / levantarse
	var wants_down := Input.is_action_pressed("down") and is_on_floor()
	if wants_down != is_down:
		is_down = wants_down
		# set_deferred evita errores físicos durante el frame actual
		col_stand.set_deferred("disabled", is_down)
		col_crouch.set_deferred("disabled", !is_down)

	# 2. Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 3. Disparos
	if Input.is_action_just_pressed("shoot") and not is_shooting:
		is_shooting = true
		shoot()
		if not is_on_floor():
			anim.play("jump shoot")
		elif is_down:
			anim.play("crouched shoot")
		else:
			anim.play("shoot")

	# 4. Salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_down:
		velocity.y = JUMP_VELOCITY

	# 5. Movimiento
	var direction := Input.get_axis("left", "right")
	if is_down:
		velocity.x = 0
		if direction != 0:
			anim.flip_h = (direction < 0)
	else:
		if direction != 0:
			velocity.x = direction * SPEED
			anim.flip_h = (direction < 0)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	actualizar_animaciones(direction)
	move_and_slide()

func shoot() -> void:
	var new_bullet = bullet.instantiate()
	var spawn_pos = bulletspawn.position
	
	if is_down:
		spawn_pos.y += 10

	var dir_sign = -1.0 if anim.flip_h else 1.0
	new_bullet.direction_bullet = PI if anim.flip_h else 0.0
	new_bullet.global_position = global_position + Vector2(abs(spawn_pos.x) * dir_sign, spawn_pos.y)
	get_parent().add_child(new_bullet)

func actualizar_animaciones(direction: float) -> void:
	if is_shooting:
		return
		
	if not is_on_floor():
		anim.play("jump")
	elif is_down:
		anim.play("crouched idle")
	else:
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")

func _on_animation_finished() -> void:
	if anim.animation in ["shoot", "jump shoot", "crouched shoot"]:
		is_shooting = false
		if is_down:
			anim.play("crouched idle")
		elif not is_on_floor():
			anim.play("jump")
		else:
			anim.play("idle")
