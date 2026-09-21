extends Area2D


@onready var relif_sound: AudioStreamPlayer2D = $relif_sound

func _on_body_entered(body: Node2D) -> void:
	# 1. Extraemos el nombre del parámetro 'body', no de 'area'
	var body_name = body.name.to_lower()
	
	# 2. Evaluamos usando 'body_name' y 'body'
	if body_name.contains("trauma") or body.is_in_group("trauma"):
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.visible = false
		
		if Hearths.hearths < 5:
			Hearths.add_hearths(1)
		
		relif_sound.play()
		await relif_sound.finished
		
		queue_free()
