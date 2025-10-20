extends CharacterBody2D
class_name Player


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Coins
@export var move_speed: float = 200.0
@export var maxHealth : int = 10
@export var health : int = maxHealth
@export var coins : int = 0
@onready var slime: Enemy = $"../slime"
@export var attack_strength: int = -2
var facing: Vector2 = Vector2.ZERO
@export var _ammount: int
var is_attacking = false
@onready var label_health: Label = $Health


func _ready():
	print("Player is ready!")
	# TODO: Add detailed character info display (Lesson 1)

func _physics_process(_delta):
	handle_movement()

func handle_movement():
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	handle_sprite(direction)
	
	# Normalize diagonal movement to prevent speed boost
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Apply movement using Godot's built-in physics
	velocity = direction * move_speed
	move_and_slide()

# BAD QUICK CODE MAYBE CHANGE
func handle_sprite(direction: Vector2) -> void:
	var prefix: String = "walk"
	if direction == Vector2.ZERO:
		prefix = "idle"
	else:
		facing = direction
	
	if facing.y > 0:
		animated_sprite.play(prefix + "_forward")
	elif facing.y < 0:
		animated_sprite.play(prefix + "_backward")
	elif facing.x < 0:
		animated_sprite.play(prefix + "_side")
		animated_sprite.flip_h = true
	elif facing.x > 0:
		animated_sprite.play(prefix + "_side")
		animated_sprite.flip_h = false
	if is_attacking:
		animated_sprite.play("fight")
	elif not is_attacking:
		if facing.y > 0:
			animated_sprite.play(prefix + "_forward")
		elif facing.y < 0:
			animated_sprite.play(prefix + "_backward")
		elif facing.x < 0:
			animated_sprite.play(prefix + "_side")
			animated_sprite.flip_h = true
		elif facing.x > 0:
			animated_sprite.play(prefix + "_side")
			animated_sprite.flip_h = false
		

func collect_pickup(_type : String, _amount : int):
	if _type == "coin":
		coins += _amount
		print("Coins: " + str(coins))
		label. _update_score_display(coins)
	elif _type == "health_potion":
		change_health(_amount)


# TODO: Add character methods here (Lesson 2)

# - level_up()
# - attack()

func change_health(_amount): 
	health += _amount
	label_health. _update_score_display(health)
	if health > maxHealth:
		health = maxHealth
		
	elif health < 1:
		die()
		print("died")
		
	print("Health: " + str(health))

func die():
	print("You died!")
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit(0)
	if event.is_action_pressed("ui_select"):
		label. _update_score_display(coins)
		attack()
		coins -= _ammount
		print("Coins: " + str(coins))
		if coins < 0:
			die()
		elif coins >= 0:
			pass

func attack():
	is_attacking = true
	if slime != null:
		if position.distance_to(slime.position)<10:
			slime.change_health(attack_strength)
	
