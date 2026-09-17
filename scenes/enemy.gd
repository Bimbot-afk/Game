extends CharacterBody2D

# --- Variables Ajustables (Cámbialas desde el Inspector) ---
@export var speed: float = 150.0
@export var change_direction_time: float = 2.0  # Cada cuántos segundos cambia de rumbo

# --- Variables Internas ---
var move_direction: float = 0.0
var timer: float = 0.0
var player: Node2D = null

func _ready() -> void:
	# Buscamos directamente al jugador usando su ruta en la escena
	if has_node("../Trauma_boy"):
		player = get_node("../Trauma_boy") as Node2D
	
	# Elige una dirección inicial al azar
	choose_random_direction()

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Lógica de mirar al Jugador
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		
		# Volteamos el sprite usando su propiedad scale de manera segura
		if direction_to_player != 0:
			# Si tu sprite original mira a la derecha, esto funcionará perfecto
			scale.x = abs(scale.x) * direction_to_player
	
	# 3. Lógica del Movimiento Aleatorio
	timer += delta
	if timer >= change_direction_time:
		choose_random_direction()
		timer = 0.0 # Reinicia el reloj

	# 4. Mover al Enemigo
	if move_direction:
		velocity.x = move_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# Función para elegir rumbo al azar
func choose_random_direction() -> void:
	# Elige aleatoriamente entre -1 (izquierda), 0 (quieto) o 1 (derecha)
	var choices = [-1.0, 0.0, 1.0]
	move_direction = choices[randi() % choices.size()]
