extends Label


func _ready():
	_update_score_display(0)

func _update_score_display(coins: int):
	text = "Monay:" + str(coins)
