extends Label


func _ready():
	_update_score_display(0)

func _update_score_display(health: int):
	text = "health:" + str(health)
