extends Node
class_name Npc

var inventory [inventory_.items]
@export var gold: int = 10
var greeting: str = "welcome to " + name +" 's shop"
var price_adjust: float = 1.0
var open = true
var can_purchase = true
var barter_amount: float = 1.2
var buy: float = .5

func display_inventory(item_number):
	for item in inventory:
		print(str(item.description))
		item.price

func _on_body_entered():
	if body is player:
		print("hello...")
	if body.is_hostile:
		print("ahhhh")
