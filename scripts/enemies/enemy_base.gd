extends CharacterBody2D
class_name EnemyBase


## ============================================================================
## ENEMY BASE - Generic enemy controller (works with all enemy types)
## ============================================================================
##
## WHAT THIS SCRIPT DOES:
## This script controls ALL enemy behavior. It's generic - a single enemy
## scene (scenes/enemies/enemy.tscn) can become any enemy type by loading
## different EnemyResource data files.
##
## Enemy behavior:
## - Chases the player when in detection range
## - Avoids clustering with other enemies (separation)
## - Deals contact damage to player
## - Takes damage from projectiles
## - Drops XP when killed
## - Optionally uses custom behavior scripts
##
## This script works with:
## - resources/enemies/*.tres (EnemyResource data files)
## - scripts/wave_spawner.gd (spawns enemies with resource data)
## - scripts/enemies/enemy_behavior.gd (optional custom AI)
##
## ============================================================================
## HOW TO CREATE NEW ENEMY TYPES:
## ============================================================================
##
## You DON'T modify this script! Instead:
##
## 1. Create new EnemyResource files (.tres) - see enemy_resource.gd
## 2. For custom AI, create behavior scripts - see enemy_behavior.gd
##
## This script automatically reads whatever data is in the EnemyResource
## and configures itself accordingly.
##
## ============================================================================
## ADVANCED: Modifying Core Enemy Behavior
## ============================================================================
##
## If you want to change how ALL enemies behave:
##
## Change chase behavior:
##   - Find: func _default_behavior()
##   - Modify the movement/rotation logic
##
## Change contact damage:
##   - Find: func _on_body_entered()
##   - Modify damage application
##
## Change separation:
##   - Find: func apply_separation()
##   - Adjust separation force calculations
##
## Add new features (e.g., ranged attacks):
##   - This requires significant code additions
##   - Consider using custom behavior scripts instead
##
## ============================================================================

@export var enemy_data: EnemyResource

# Current stats (loaded from EnemyResource and scaled by wave)
var max_health: float = 50.0
var current_health: float = 50.0
var contact_damage: float = 10.0
var move_speed: float = 100.0
var detection_range: float = 1000.0
var xp_value: int = 10

# References
## Player reference - set by WaveSpawner when enemy is spawned
## Note: %Player doesn't work for runtime-instantiated nodes, so WaveSpawner sets this directly
var player: Player = null
var sprite: Node = null

# Custom behavior (optional)
## If enemy_data has a custom_behavior_script, this will be instantiated
var custom_behavior: EnemyBehavior = null

# Contact damage cooldown
var damage_cooldown: float = 0.0
var damage_cooldown_time: float = 1.0

# XP drop scene
@export var xp_drop_scene: PackedScene


func _ready() -> void:
	# Add to enemies group for targeting
	add_to_group("enemies")

	# Set collision layers (Layer 2 = enemies)
	collision_layer = 2
	collision_mask = 0  # Don't collide with anything (let Area2D handle player detection)

	# Get sprite node (could be Sprite2D or AnimatedSprite2D)
	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = get_node_or_null("AnimatedSprite2D")

	# WaveSpawner will call load_from_resource() after _ready() runs
	# So we don't need to load anything here


## Load enemy stats from an EnemyResource with wave scaling
## Returns true if successfully loaded
func load_from_resource(resource: EnemyResource, wave_number: int) -> bool:
	if not resource:
		return false

	enemy_data = resource

	# Get scaled stats based on wave
	max_health = resource.get_scaled_health(wave_number)
	current_health = max_health
	contact_damage = resource.get_scaled_damage(wave_number)
	move_speed = resource.get_scaled_speed(wave_number)
	xp_value = resource.get_scaled_xp(wave_number)

	detection_range = resource.detection_range

	# Set visual (sprite is already set in _ready())
	if sprite:
		if resource.animated_frames and sprite is AnimatedSprite2D:
			sprite.sprite_frames = resource.animated_frames
			sprite.scale = Vector2(resource.sprite_scale, resource.sprite_scale)
			sprite.play("idle")
		elif resource.enemy_texture and sprite is Sprite2D:
			sprite.texture = resource.enemy_texture
			sprite.scale = Vector2(resource.sprite_scale, resource.sprite_scale)

	# Load custom behavior if specified
	if resource.custom_behavior_script:
		# Instantiate the custom behavior script
		custom_behavior = resource.custom_behavior_script.new()
		if custom_behavior and custom_behavior is EnemyBehavior:
			add_child(custom_behavior)
			custom_behavior.initialize(self, player)
		else:
			push_error("Custom behavior script must extend EnemyBehavior")
			custom_behavior = null

	return true


func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return

	# Update damage cooldown
	if damage_cooldown > 0:
		damage_cooldown -= delta

	# Use custom behavior if available, otherwise use default behavior
	if custom_behavior:
		# Custom behavior handles movement
		velocity = custom_behavior.process_behavior(delta)
		move_and_slide()

		# Custom behavior can handle attacks
		custom_behavior.process_attack(delta)
	else:
		# Default behavior: chase the player
		_default_behavior(delta)


## Default enemy behavior: chase the player
func _default_behavior(delta: float) -> void:
	# Check if player is in detection range
	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player <= detection_range:
		# Move toward player
		var direction_to_player = (player.global_position - global_position).normalized()

		# Apply separation from other enemies if enabled
		if enemy_data and enemy_data.uses_separation:
			direction_to_player = apply_separation(direction_to_player)

		velocity = direction_to_player * move_speed
		move_and_slide()

		# Flip sprite based on movement direction
		if sprite and direction_to_player.x != 0:
			if sprite is Sprite2D:
				sprite.flip_h = direction_to_player.x < 0
			elif sprite is AnimatedSprite2D:
				sprite.flip_h = direction_to_player.x < 0


## Apply separation force to avoid clustering
func apply_separation(current_direction: Vector2) -> Vector2:
	var separation_force = Vector2.ZERO
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in nearby_enemies:
		if enemy == self or not enemy is Node2D:
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance < enemy_data.separation_distance and distance > 0:
			var away_vector = (global_position - enemy.global_position).normalized()
			separation_force += away_vector / distance

	# Blend current direction with separation force
	var final_direction = (current_direction + separation_force * 0.5).normalized()
	return final_direction


## Take damage from player weapons
## Returns true if this damage killed the enemy
func take_damage(amount: float) -> bool:
	current_health -= amount

	# Visual feedback (optional: flash sprite)
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE

	if current_health <= 0:
		die()
		return true

	return false


## Handle enemy death
## Returns true if death was handled successfully
func die() -> bool:
	# Drop XP
	if xp_drop_scene and player:
		var xp_drop = xp_drop_scene.instantiate()
		xp_drop.xp_amount = xp_value
		xp_drop.global_position = global_position
		# Add to parent scene so it can access %Player unique name
		get_parent().add_child(xp_drop)

	# Remove enemy
	queue_free()
	return true


## Handle collision with player (contact damage)
func _on_body_entered(body: Node2D) -> void:
	# Only deal damage if this enemy type can attack
	if not enemy_data or not enemy_data.can_attack:
		return

	if body is Player and damage_cooldown <= 0:
		body.take_damage(contact_damage)
		damage_cooldown = damage_cooldown_time
