extends npc

#var inventory [inventory_items]
@export var gold: int = 10
var greeting: String = "welcome to " + name +" 's shop"
var price_adjust: float = 1.0
var open = true
var can_purchase = true
var barter_amount: float = 1.2
var buy: float = .5
@export var description: String

func display_inventory(item_number):
	for item in inventory:
		print(str(item.description))
		item.price

func _on_body_entered():
	if body is player:
		print("hello...")
	if body.is_hostile:
		print("ahhhh")
