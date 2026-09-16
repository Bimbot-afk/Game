extends CharacterBody2D

var direction_bullet: float = 0.0
var speed_bullet: float = 1000.0

func _ready():
	rotation = direction_bullet

func _physics_process(delta: float):
	velocity = Vector2(speed_bullet, 0).rotated(direction_bullet)
	move_and_slide() # ¡NUEVO: Obligatorio para que los CharacterBody2D se muevan!


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
