extends CanvasLayer
class_name LevelUpUI

## ============================================================================
## LEVEL UP UI - Upgrade selection screen
## ============================================================================
##
## WHAT THIS SCRIPT DOES:
## This script manages the level-up screen that appears when the player gains
## a level. It:
## - Pauses the game
## - Shows 3 random upgrade options
## - Creates buttons dynamically from StatUpgradeResource data
## - Applies the chosen upgrade to the player
## - Unpauses and hides itself after selection
##
## This script works with:
## - scripts/player.gd (connects to level_up signal)
## - resources/upgrades/*.tres (StatUpgradeResource files)
## - scripts/resources/stat_upgrade_resource.gd (upgrade definitions)
##
## ============================================================================
## HOW TO ADD MORE UPGRADES TO THE POOL:
## ============================================================================
##
## Create new upgrade variants (NO CODE CHANGES):
##   - See stat_upgrade_resource.gd for instructions
##   - Duplicate existing upgrade .tres files
##   - Change amount, name, description
##
## Add new upgrade TYPES (REQUIRES CODE):
##   - See stat_upgrade_resource.gd for detailed instructions
##   - Add to UpgradeType enum
##   - Add upgrade function to player.gd
##   - Add case to match statement
##
## ============================================================================
## COMMON MODIFICATIONS:
## ============================================================================
##
## Change number of upgrade options:
##   - Find: @export var upgrade_choices_count: int = 3
##   - Change to 2, 4, 5, etc.
##
## Show all upgrades instead of random:
##   - Modify show_upgrade_options()
##   - Don't shuffle, just show all available_upgrades
##
## Add upgrade rarity system:
##   - Add rarity property to StatUpgradeResource
##   - Weight random selection based on rarity
##
## Add reroll button:
##   - Add button that regenerates upgrade options
##   - Costs gold or has limited uses
##
## ============================================================================


@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var options_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/OptionsContainer

@onready var player: Player = %Player
@onready var hud: HUD = $"../HUD"


## Available upgrade resources
@export var available_upgrades: Array[StatUpgradeResource] = [] 


func _ready() -> void:
	player.level_up.connect(_on_player_level_up)

	# Hide by default
	hide()



func _on_player_level_up(new_level: int) -> void:
	show_upgrade_options(new_level)


## Show the upgrade selection screen
func show_upgrade_options(level: int) -> void:
	# Pause game
	get_tree().paused = true

	# Update title
	title_label.text = "Level " + str(level) + " - Choose an Upgrade!"

	# Clear existing options
	for child in options_container.get_children():
		child.queue_free()

	# Pick up to 3 random upgrades to offer (or all if less than 3)
	var offered_upgrades = available_upgrades.duplicate()
	offered_upgrades.shuffle()
	var num_to_offer = min(3, offered_upgrades.size())
	offered_upgrades = offered_upgrades.slice(0, num_to_offer)

	# Create buttons for each upgrade resource
	for upgrade_resource in offered_upgrades:
		var button = Button.new()
		button.text = upgrade_resource.get_display_text()
		button.custom_minimum_size = Vector2(400, 60)
		button.pressed.connect(_on_upgrade_selected.bind(upgrade_resource))
		options_container.add_child(button)

	show()


## Handle when player selects an upgrade
func _on_upgrade_selected(upgrade) -> void:
	if not player or not upgrade:
		return

	# Apply the upgrade using the resource's method
	# upgrade should be a StatUpgradeResource
	upgrade.apply_to_player(player)
	hud._update_stats_display()
	# Hide UI and unpause
	hide()
	get_tree().paused = false
