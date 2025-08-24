extends CharacterBody2D

## Player Controller
##
## Handles player movement, animations, and footstep audio based on surface materials.
## Supports walking, sprinting, and attacking with proper state management.
##
## Features:
## - Movement with walk/sprint speeds
## - Surface material detection for footstep sounds
## - Attack system with movement lockout
## - Animation state management
## - Automatic sprite flipping based on movement direction
##
## Requirements:
## - AnimationPlayer with "idle", "walk", "sprint", and "attack" animations
## - Footstep animation events calling _on_footstep_left() and _on_footstep_right()
## - TileMap with custom data "material" for surface detection
## - AudioManager autoload for footstep sounds

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tile_map_layer: TileMapLayer = $"../TilemapLayers/TileMapLayer"
## Movement speeds
const WALK_SPEED: float   = 100.0
const SPRINT_SPEED: float = 250.0
## Fallback surface material when none is detected
const FALLBACK_MATERIAL: String = "grass"
## Player state flags
var is_attacking: bool = false
var can_move: bool     = true
## Current movement state for footstep detection
var _current_movement_state: String = "idle"
## Cache for the last detected surface material to avoid unnecessary lookups
var _cached_surface_material: String = FALLBACK_MATERIAL
var _last_tile_position: Vector2i    = Vector2i.MAX  # Invalid position to force initial check


## Initialize player and validate dependencies
func _ready() -> void:
	add_to_group("player")
	_connect_signals()
	_validate_dependencies()


## Connect necessary signals with error handling
func _connect_signals() -> void:
	if not animation_player:
		push_error("AnimationPlayer node not found at path '$AnimationPlayer'")
		return

	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)


## Validate required node dependencies
func _validate_dependencies() -> void:
	if not tile_map_layer:
		push_error("TileMapLayer not found at path '../TilemapLayers/TileMapLayer'")
		push_error("Surface material detection will use fallback material: " + FALLBACK_MATERIAL)

	if not sprite_2d:
		push_error("Sprite2D node not found - sprite flipping will not work")

	if not animation_player:
		push_error("AnimationPlayer node not found - animations will not work")


## Main physics update loop
## @param _delta: Time elapsed since last frame (unused)
func _physics_process(_delta: float) -> void:
	# Handle attack input
	if Input.is_action_just_pressed("Attack") and _can_attack():
		_start_attack()
		return

	# Skip movement if player cannot move
	if not _can_move_freely():
		return

	_handle_movement()


## Check if player can initiate an attack
## @return: True if the player can attack, false otherwise
func _can_attack() -> bool:
	return not is_attacking and can_move


## Check if player can move freely
## @return: True if the player can move, false otherwise
func _can_move_freely() -> bool:
	return not is_attacking and can_move


## Handle player movement, animations, and physics
func _handle_movement() -> void:
	var input_vector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var is_sprinting: bool    = Input.is_action_pressed("Sprint") and input_vector != Vector2.ZERO

	# Apply velocity
	velocity = input_vector.normalized() * _get_movement_speed(is_sprinting)

	# Update sprite direction
	_update_sprite_direction(velocity.x)

	# Update animations based on movement state
	_update_movement_animation(input_vector, is_sprinting)

	# Move the character
	move_and_slide()


## Get movement speed based on sprinting state
## @param is_sprinting: Whether the player is sprinting
## @return: The appropriate movement speed
func _get_movement_speed(is_sprinting: bool) -> float:
	return SPRINT_SPEED if is_sprinting else WALK_SPEED


## Update sprite horizontal flip based on movement direction
## @param velocity_x: The horizontal component of velocity
func _update_sprite_direction(velocity_x: float) -> void:
	if sprite_2d and velocity_x != 0.0:
		sprite_2d.flip_h = velocity_x < 0.0


## Update movement animations based on input and state
## @param input_vector: The current input direction vector
## @param is_sprinting: Whether the player is sprinting
func _update_movement_animation(input_vector: Vector2, is_sprinting: bool) -> void:
	if not animation_player:
		return

	var target_animation: String

	if input_vector == Vector2.ZERO:
		target_animation = "idle"
		_current_movement_state = "idle"
	elif is_sprinting:
		target_animation = "sprint"
		_current_movement_state = "sprint"
	else:
		target_animation = "walk"
		_current_movement_state = "walk"

	# Only change animation if it's different from current
	if animation_player.current_animation != target_animation:
		animation_player.play(target_animation)


## Called by animation events when left foot hits the ground
func _on_footstep_left() -> void:
	_play_footstep()


## Called by animation events when right foot hits the ground
func _on_footstep_right() -> void:
	_play_footstep()


## Play footstep sound based on current surface and movement state
func _play_footstep() -> void:
	# Only play footsteps during movement animations
	if _current_movement_state == "idle":
		return

	var surface_material: String = _get_current_material()
	var is_running: bool         = _current_movement_state == "sprint"

	# Use FootstepManager instead of AudioManager for consistency
	FootstepManager.play_footstep_sound(surface_material, is_running, global_position)


## Get current surface material with caching optimization
## @return: The current surface material string, or fallback material if none found
func _get_current_material() -> String:
	if not tile_map_layer:
		return FALLBACK_MATERIAL

	# Get current tile position
	var current_tile_pos: Vector2i = tile_map_layer.local_to_map(tile_map_layer.to_local(global_position))

	# Use cached material if we're still on the same tile
	if current_tile_pos == _last_tile_position:
		return _cached_surface_material

	# Update cache
	_last_tile_position = current_tile_pos

	# Get tile data and extract material
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(current_tile_pos)

	if tile_data and tile_data.get_custom_data("material"):
		_cached_surface_material = str(tile_data.get_custom_data("material"))
	else:
		_cached_surface_material = FALLBACK_MATERIAL

	return _cached_surface_material


## Start attack sequence with movement lockout
func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	_current_movement_state = "attacking"

	if animation_player:
		animation_player.play("attack")
	else:
		# Fallback if no AnimationPlayer - end attack immediately
		push_warning("No AnimationPlayer found - attack animation skipped")
		_end_attack()


## End attack sequence and restore normal state
func _end_attack() -> void:
	is_attacking = false
	_current_movement_state = "idle"


## Handle animation finished events
## @param animation_name: Name of the animation that finished
func _on_animation_player_animation_finished(animation_name: String) -> void:
	match animation_name:
		"attack":
			_end_attack()
		_:
			pass  # Handle other animations if needed
		
