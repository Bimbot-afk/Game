extends Node

var hearths = 5

signal hearths_changed(hearths)

func refresh_hearths(delta):
	hearths-=delta
	hearths_changed.emit(hearths)
