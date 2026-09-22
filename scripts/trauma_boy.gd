extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var col_stand: CollisionShape2D = $CollisionStand
@onready var col_crouch: CollisionShape2D = $CollisionCrouch
@onready var bulletspawn: Node2D = $bulletspawn
@onready var piu_sound: AudioStreamPlayer2D = $piu_trauma
@onready var hurth_sound: AudioStreamPlayer2D = $hurt_sound
@onready var dead_sound: AudioStreamPlayer2D = $lose_hearth



var bullet = preload("res://scenes/bullet.tscn")
var is_shooting: bool = false
var is_down: bool = false
var is_dead: bool = false
var is_reliving: bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	# Estado inicial: de pie
	col_stand.disabled = false
	col_crouch.disabled = true

func _physics_process(delta: float) -> void:
	# Compuerta de colapso de estado: si está muerto, solo obedece a la gravedad.
	if is_dead or is_reliving:
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# 1. Cambiar colisiones al agacharse / levantarse
	var wants_down := Input.is_action_pressed("down") and is_on_floor()
	if wants_down != is_down:
		is_down = wants_down
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
	piu_sound.play()
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
	if anim.animation == "relif":
		is_reliving = false
		anim.play("idle")
		return

	if anim.animation in ["shoot", "jump shoot", "crouched shoot"]:
		is_shooting = false
		if is_down:
			anim.play("crouched idle")
		elif not is_on_floor():
			anim.play("jump")
		else:
			anim.play("idle")
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_dead or is_reliving:
		return

	var body_area = area.name.to_lower()
	
	if body_area.contains("proyectile") or area.is_in_group("proyectile"):
		hurth_sound.play()
		area.queue_free() 
		GlobalLife.refresh_life(1)
		
		if GlobalLife.life <= 0:
			velocity = Vector2.ZERO	
			
			# Sanitización de variables para evitar el interbloqueo
			is_shooting = false
			
			Hearths.refresh_hearths(1)
			
			if Hearths.hearths > 0:
				is_reliving = true
				GlobalLife.life = 5
				relife()
			else:
				is_dead = true
				dead()

			
func relife():
	anim.play("death")
	dead_sound.play()
	anim.play("relif")	
func dead():
	anim.play("death")
	await anim.animation_finished 
	get_tree().change_scene_to_file("res://scenes/lose.tscn")
	
