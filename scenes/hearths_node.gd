extends Node

signal hearths_changed(current_amount: int)

var hearths: int = 5:
	set(value):
		hearths = value
		hearths_changed.emit(hearths)

func _ready() -> void:
	Hearths.hearths_changed.connect(_on_hearths_changed)

func _on_hearths_changed(current_hearths: int) -> void:
	if current_hearths <= 4 and has_node("hearth5"):
		$hearth5.queue_free()
	elif current_hearths <= 3 and has_node("hearth4"):
		$hearth4.queue_free()
	elif current_hearths <= 2 and has_node("hearth3"):
		$hearth3.queue_free()
	elif current_hearths <= 1 and has_node("hearth2"):
		$hearth2.queue_free()
	elif current_hearths <= 0 and has_node("hearth"):
		$hearth.queue_free()
	
