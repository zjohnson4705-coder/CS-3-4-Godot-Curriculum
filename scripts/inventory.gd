extends Node2D
class_name inventory

@export var my_inventory: Array[inventory_item] = []
var current_item: int = 0
var maxSize = 5

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory_up"):
		current_item -= 1
		if current_item < 0:
			current_item = my_inventory.size()-1
		print_inventory(current_item)
	if Input.is_action_just_pressed("inventory_down"):
		current_item += 1
		if current_item > my_inventory.size()-1:
			current_item = 0
			print_inventory(current_item)

	if Input.is_action_just_pressed("inventory_drop"):
		remove_inventory(current_item)
		print_inventory(current_item)

func print_inventory(_item : int):
	print("The current item is " + my_inventory[current_item].name)
	print("it costs " + str(my_inventory[current_item].cost))
	print(my_inventory[current_item].description)
#some other stuff goes here

func add_inventory(item : inventory_item):
	if my_inventory.size() < maxSize:
		my_inventory.append(item)
	if my_inventory.size() > maxSize:
		print("our inventory is full, consider dropping an item or using an item first")


func remove_inventory(_index : int):
	my_inventory.remove_at(_index)
	pass
