extends npc

@onready var sprite: Sprite2D = $Sprite2D





func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	pass


func _on_detection_radius_body_entered(body: Node2D) -> void:
	super._on_detection_radius_body_entered(body)
	if body.is_in_group("player"):
		print("angry")
		is_hostile = true


func _on_detection_radius_body_exited(body: Node2D) -> void:
	super._on_detection_radius_body_exited(body)
	if body.is_in_group("player"):
		print ("yas")
		is_hostile = false
