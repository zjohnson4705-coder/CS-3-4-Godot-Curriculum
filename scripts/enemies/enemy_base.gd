extends npc
class_name Enemy
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
		print ("not touching player")
		is_hostile = false



#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#print("gotcha")
		#get_tree().reload_current_scene()
		
func change_health(_amount):
	health+= _amount
	print("Slime Health " + str(health))
	if health <= 0:
		queue_free()
