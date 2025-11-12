extends Resource
class_name StatUpgradeResource

## ============================================================================
## STAT UPGRADE RESOURCE - Player level-up upgrades
## ============================================================================
##
## WHAT THIS SCRIPT DOES:
## This is a RESOURCE SCRIPT that defines upgrades the player can choose when
## leveling up (health boosts, speed boosts, damage boosts, etc.).
##
## This resource works with:
## - scripts/ui/level_up_ui.gd (displays upgrade choices)
## - scripts/player.gd (applies upgrades to player stats)
##
## ============================================================================
## HOW TO CREATE NEW UPGRADE TYPES (REQUIRES CODE CHANGES):
## ============================================================================
##
## Unlike other resources, adding a NEW TYPE of upgrade requires modifying code
## in TWO places. However, creating VARIANTS of existing upgrades doesn't.
##
## ──────────────────────────────────────────────────────────────────────────
## EASY: Create variant of existing upgrade (NO CODE CHANGES):
## ──────────────────────────────────────────────────────────────────────────
##
## If you just want a different amount (e.g., "Small Health Boost" vs
## "Large Health Boost"), you can duplicate .tres files:
##
## 1. Navigate to: resources/upgrades/
## 2. Duplicate health_upgrade.tres
## 3. Rename it (e.g., "large_health_upgrade.tres")
## 4. Change the "amount" value (e.g., 50 instead of 20)
## 5. Change the name and description
## 6. Add to player's available_upgrades array in scenes/player.tscn
##
## ──────────────────────────────────────────────────────────────────────────
## ADVANCED: Add a completely NEW upgrade type (REQUIRES CODE):
## ──────────────────────────────────────────────────────────────────────────
##
## To add a new stat type (like SPEED or DAMAGE), follow these steps:
##
## STEP 1: Add to the UpgradeType enum (in THIS file, line ~9):
##    enum UpgradeType {
##        HEALTH,
##        SPEED,      # <-- Add new type here
##        DAMAGE,     # <-- And here
##    }
##
## STEP 2: Add upgrade function in player.gd (around line 145):
##    func upgrade_speed(amount: float) -> bool:
##        move_speed += amount
##        print("Speed increased by ", amount, "! New speed: ", move_speed)
##        return true
##
## STEP 3: Add case to match statement (in THIS file, line ~115):
##    match stat_type:
##        UpgradeType.HEALTH:
##            return player.upgrade_health(amount)
##        UpgradeType.SPEED:              # <-- Add new case
##            return player.upgrade_speed(amount)
##        UpgradeType.DAMAGE:             # <-- And here
##            return player.upgrade_damage(amount)
##
## STEP 4: Create the resource file:
##    - Duplicate resources/upgrades/health_upgrade.tres
##    - Set stat_type to your new type (SPEED, DAMAGE, etc.)
##    - Set amount and description
##
## STEP 5: Add to player's available_upgrades:
##    - Open LevelUpUI.tscn
##    - Find "Available Upgrades" array
##    - Add your new upgrade resource
##
## ============================================================================

## Enum defining available upgrade types
enum UpgradeType {
	HEALTH,    ## Increases max health
	SPEED,
	DAMAGE
	
}

@export_group("Upgrade Identity")
## Unique identifier for this upgrade
@export var upgrade_id: String = ""

## Display name shown to the player (e.g., "Max Health +20")
@export var upgrade_name: String = "Unknown Upgrade"

## Description explaining what this upgrade does
@export var description: String = ""

## Optional icon to display with the upgrade
@export var icon: Texture2D

@export_group("Upgrade Effect")
## Type of stat to upgrade
@export var stat_type: UpgradeType = UpgradeType.HEALTH

## Amount to increase the stat by
@export var amount: float = 0.0


## Apply this upgrade to the player
## Returns true if successfully applied
func apply_to_player(player: Player) -> bool:
	if not player:
		return false

	match stat_type:
		UpgradeType.HEALTH:
			return player.upgrade_health(amount)
		UpgradeType.SPEED:
			return player.upgrade_speed(amount)
		UpgradeType.DAMAGE:
			return player.upgrade_damage(amount)
		_:
			push_error("Unknown stat_type: " + str(stat_type))
			return false


## Get the full display text for this upgrade
func get_display_text() -> String:
	return upgrade_name + "\n" + description
