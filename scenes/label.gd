extends Label

@export var coins : int

func _ready():
	_update_score_display()

func _update_score_display():
	text = "Monay:" + str(coins)
