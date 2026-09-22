extends Node2D



func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.name.to_lower().contains("trauma"):
		return

	if GlobalCoin.coin >= 80:
		get_tree().change_scene_to_file("res://scenes/win.tscn") # Replace with function body.
