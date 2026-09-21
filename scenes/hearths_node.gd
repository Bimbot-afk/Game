extends Node

signal hearths_changed(current_amount: int)

var hearths: int = 5:
	set(value):
		hearths = value
		hearths_changed.emit(hearths)

func _ready() -> void:
	Hearths.hearths_changed.connect(_on_hearths_changed)

func _on_hearths_changed(current_hearths: int) -> void:
	if has_node("hearth"):
		$hearth.visible = current_hearths >= 1
	if has_node("hearth2"):
		$hearth2.visible = current_hearths >= 2
	if has_node("hearth3"):
		$hearth3.visible = current_hearths >= 3
	if has_node("hearth4"):
		$hearth4.visible = current_hearths >= 4
	if has_node("hearth5"):
		$hearth5.visible = current_hearths >= 5
