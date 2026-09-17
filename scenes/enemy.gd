extends CharacterBody2D

# --- Variables Cinemáticas y de Control Espacial ---
@export var speed: float = 400.0
@export var change_direction_time: float = 2.0  
@export var keep_distance: float = 450.0 
@export var distance_tolerance: float = 10.0 

# --- Variables Estocásticas y de Ráfaga ---
@export var min_fire_time: float = 1.5
@export var max_fire_time: float = 2.0
@export var burst_amount: int = 5          # Cantidad de tiros por ráfaga
@export var burst_fire_rate: float = 0.5  # Tiempo entre cada bala de la ráfaga

var current_fire_rate: float = 0.0              

# --- Referencias de Nodos ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D2
@onready var collision_walk: CollisionShape2D = $walk
@onready var collision_shoot: CollisionShape2D = $shoot
@onready var collision_death: CollisionShape2D = $death
@onready var enemyBullet: Node2D = $enemyBullet

# --- Variables de Estado Interno ---
var bullet = preload("res://scenes/bullet_enemy.tscn")
var move_direction: float = 0.0
var timer: float = 0.0
var shoot_timer: float = 0.0
var player: Node2D = null
var life: float = 7

var is_dead: bool = false
var is_shooting: bool = false
var is_locked_shooting: bool = false # Nuevo estado de anclaje
var burst_counter: int = 0           # Contador de balas disparadas

func _ready() -> void:
	if has_node("../Trauma_boy"):
		player = get_node("../Trauma_boy") as Node2D
	
	choose_random_direction()
	_switch_hitbox("walk")
	_randomize_fire_rate()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. Aplicación vectorial de gravedad: NUNCA se interrumpe
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Control Lógico de IA
	if player:
		var distance_to_player = player.global_position.x - global_position.x
		var abs_dist = abs(distance_to_player)
		var direction_to_player = sign(distance_to_player)
		
		# ORIENTACIÓN VISUAL: Permite que gire aunque esté bloqueado (Edge Case resuelto)
		if direction_to_player != 0 and not is_shooting:
			anim.flip_h = (direction_to_player < 0)
		
		# LÓGICA DE MOVIMIENTO VS BLOQUEO
		if not is_locked_shooting:
			if abs_dist < keep_distance - distance_tolerance:
				_move_enemy(-direction_to_player * speed)
			elif abs_dist > keep_distance + distance_tolerance:
				_move_enemy(direction_to_player * speed)
			else:
				# Zona de equilibrio alcanzada: Bloqueamos el estado para iniciar ráfaga
				is_locked_shooting = true
				
		# EJECUCIÓN DEL ESTADO BLOQUEADO
		if is_locked_shooting:
			velocity.x = move_toward(velocity.x, 0, speed) # Anulamos vector de traslación
			
			if not is_shooting:
				_change_state_and_animation("idle")
				
			_handle_burst_shooting(delta)
			
	else:
		is_shooting = false
		timer += delta
		if timer >= change_direction_time:
			choose_random_direction()
			timer = 0.0

		if move_direction != 0.0:
			velocity.x = move_direction * speed
			_change_state_and_animation("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			_change_state_and_animation("idle")
			
	move_and_slide()

# --- GESTIÓN TOPOLÓGICA Y DE ESTADOS ---

func _switch_hitbox(active_hitbox: String) -> void:
	var use_walk_hitbox = (active_hitbox == "walk" or active_hitbox == "idle")
	collision_walk.set_deferred("disabled", not use_walk_hitbox)
	collision_shoot.set_deferred("disabled", active_hitbox != "shoot")
	collision_death.set_deferred("disabled", active_hitbox != "death")

func _move_enemy(target_velocity_x: float) -> void:
	is_shooting = false
	velocity.x = target_velocity_x
	_change_state_and_animation("walk")

func choose_random_direction() -> void:
	var choices = [-1.0, 0.0, 1.0]
	move_direction = choices[randi() % choices.size()]

# --- LÓGICA DE DISPARO SECUENCIAL ---

func _randomize_fire_rate() -> void:
	current_fire_rate = randf_range(min_fire_time, max_fire_time)
	
func shoot() -> void:
	# Instancia estrictamente 1 bala. La repetición se maneja en el contador temporal.
	var new_bullet = bullet.instantiate()
	var spawn_pos = enemyBullet.position
	
	var dir_sign = -1.0 if anim.flip_h else 1.0
	new_bullet.direction_bullet = PI if anim.flip_h else 0.0
	
	new_bullet.global_position = global_position + Vector2(abs(spawn_pos.x) * dir_sign, spawn_pos.y)
	get_parent().add_child(new_bullet)

func _handle_burst_shooting(delta: float) -> void:
	shoot_timer += delta
	
	# El primer disparo espera el tiempo aleatorio. Los demás de la ráfaga esperan 'burst_fire_rate'
	var delay = current_fire_rate if burst_counter == 0 else burst_fire_rate
	
	if shoot_timer >= delay:
		_change_state_and_animation("shoot")
		is_shooting = true
		shoot() # Disparamos una bala
		burst_counter += 1
		shoot_timer = 0.0
		
		# Verificamos si completó la ráfaga
		if burst_counter >= burst_amount:
			is_locked_shooting = false # Liberamos a la IA para que vuelva a moverse
			burst_counter = 0
			_randomize_fire_rate()
	
	if is_shooting and anim.frame >= anim.sprite_frames.get_frame_count("shoot") - 1:
		is_shooting = false

func _change_state_and_animation(state_name: String) -> void:
	if anim.animation != state_name:
		anim.play(state_name)
		_switch_hitbox(state_name)

# --- Interacciones Físicas ---
func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_dead:
		return

	var body_area = area.name.to_lower()
	
	if body_area.contains("bullet") or area.is_in_group("bullet"):
		area.queue_free() 
		life -= 1
		
		if life <= 0:
			is_dead = true
			velocity = Vector2.ZERO	
			_change_state_and_animation("death")	
			await anim.animation_finished
