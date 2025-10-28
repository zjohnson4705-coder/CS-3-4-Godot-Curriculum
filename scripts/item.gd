@tool
extends Resource
class_name inventory_item

@export var name: String 
@export var description: String
@export var price: int
@export var type: String
@export var cost: int
@export var image: Texture2D

func ready():
	print ("Im ready!-CLimmia")
