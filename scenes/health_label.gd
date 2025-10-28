extends Label
@export var player = get_parent()

func _ready():
	_update_score_display(10)

func _update_score_display(health: int):
	text = "health:" + str(health)
