extends Node

var coin = 0

signal coin_changed(coin)

func refresh_coin(delta):
	coin+=delta
	coin_changed.emit(coin)
