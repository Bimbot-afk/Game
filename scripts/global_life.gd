extends Node

var life = 5

signal life_changed(life)

func refresh_life(delta):
	life-=delta
	life_changed.emit(life)
