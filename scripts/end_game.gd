extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	# 1. Filtra para que SOLO afecte al jugador (asumiendo que tu personaje se llama "Player")
	if not body.name.to_lower().contains("player"):
		return # Si no es el jugador, ignora el objeto y no hace nada

	# 2. Ahora que sabemos que es el jugador, revisamos las condiciones de victoria
	if GlobalCoin.coin >= 80:
		get_tree().change_scene_to_file("res://scenes/win.tscn")
