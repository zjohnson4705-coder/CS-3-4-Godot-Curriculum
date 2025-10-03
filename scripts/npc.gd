extends CharacterBody2D
class_name npc

@onready var player: = %Player

@export var health : int = 10
@export var speed : int = 50
@export var is_hostile: bool = false
@export var move_points : Array[Vector2] = []
@export var move_point : int = 0
@export var dialogue : Array[String] = []
@export var inventory : Array[String] = []
@export var inventory_drop : int = 0
#@export var state
@export var type : String = ""
@export var target : Vector2

func _ready() -> void:
	
	pass

func _physics_process(delta: float) -> void:
	movement(delta)
	move_and_slide()
	pass
	

func _on_detection_radius_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_detection_radius_body_exited(body: Node2D) -> void:
	pass # Replace with function body.



func movement(_delta):
	if is_hostile:
		target = player.position
	else:
		target = move_points[move_point]
	var target_direction = position.direction_to(target)
	velocity = speed * target_direction
	if position.distance_to(target)<10:
		move_point+=1
		if move_point > move_points.size()-1:
			move_point = 0
	
	pass
