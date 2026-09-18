extends Area2D

var direction_bullet: float = 0.0
@export var speed_bullet: float = 1000.0

func _ready() -> void:
	rotation = direction_bullet

func _process(delta: float) -> void:
	# En un Area2D el movimiento se hace sumando la posición directamente con vectores multiplicados por delta
	var movement = Vector2(speed_bullet, 0).rotated(direction_bullet)
	position += movement * delta
	add_to_group("proyectile")

# Se destruye automáticamente al salir de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
