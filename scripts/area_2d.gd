extends Area2D

@onready var coin_sound: AudioStreamPlayer2D = $coin_sound

func _on_body_entered(body: Node2D) -> void:
	# 1. Extraemos el nombre del parámetro 'body', no de 'area'
	var body_name = body.name.to_lower()
	
	# 2. Evaluamos usando 'body_name' y 'body'
	if body_name.contains("trauma") or body.is_in_group("trauma"):
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.visible = false
		
		GlobalCoin.refresh_coin(1)
		
		coin_sound.play()
		await coin_sound.finished
		
		queue_free()
