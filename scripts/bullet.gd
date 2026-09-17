extends Area2D

var direction_bullet: float = 0.0
@export var speed_bullet: float = 1000.0

func _ready() -> void:
	rotation = direction_bullet
	# Agrega la bala al grupo de manera automática para que el enemigo la reconozca
	add_to_group("bullet")

func _process(delta: float) -> void:
	# En un Area2D el movimiento se hace sumando la posición directamente con vectores multiplicados por delta
	var movement = Vector2(speed_bullet, 0).rotated(direction_bullet)
	position += movement * delta

# Se destruye automáticamente al salir de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# --- DETECCIÓN DE IMPACTO CON EL ENEMIGO ---
# Conecta la señal 'body_entered' de tu nodo raíz 'bullet' (el Area2D principal)
func _on_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	var body_name = body.name.to_lower()
	
	# Si choca con el enemigo por nombre o grupo
	if body_name.contains("enemy") or body.is_in_group("enemy"):
		# Usamos call_deferred para darle tiempo al enemigo de procesar el golpe antes de borrar la bala
		queue_free()
