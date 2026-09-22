extends Label


func _process(delta: float) -> void:
	$".".text="Coins: "+ str(GlobalCoin.coin)+"/80"
