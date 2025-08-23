extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tile_map_layer: TileMapLayer = $"../TilemapLayers/TileMapLayer"
const WALK_SPEED: float                   = 100.0
const SPRINT_SPEED: float                 = 250.0
const FALLBACK_MATERIAL: String           = "grass"
var is_attacking: bool                    = false
var can_move: bool                        = true


func _ready() -> void:
	add_to_group("player")
	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)

	if not tile_map_layer:
		push_error("TileMapLayer introuvable au chemin '../TilemapLayers/TileMapLayer'")


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Attack") and not is_attacking and can_move:
		_start_attack()
		return

	# If attacking or cannot move, skip movement handling
	if is_attacking or not can_move:
		return

	_handle_movement()


func _handle_movement() -> void:
	var input_vector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var is_sprinting: bool    = Input.is_action_pressed("Sprint")

	# Apply velocity
	velocity = input_vector.normalized() * (SPRINT_SPEED if is_sprinting else WALK_SPEED)

	# Flip sprite
	if velocity.x != 0.0:
		sprite_2d.flip_h = velocity.x < 0.0

	# Play animations
	if input_vector == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("sprint" if is_sprinting else "walk")

	move_and_slide()


func _on_footstep_left() -> void:
	"""Appelée par l'Animation Event quand le pied gauche touche le sol"""
	_play_footstep()


func _on_footstep_right() -> void:
	"""Appelée par l'Animation Event quand le pied droit touche le sol"""
	_play_footstep()


func _play_footstep() -> void:
	var surface_material: String = _get_current_material()
	var is_running: bool         = animation_player.current_animation == "sprint"
	AudioManager.play_footstep_sound(surface_material, is_running, global_position)


func _get_current_material() -> String:
	if not tile_map_layer:
		return FALLBACK_MATERIAL

	var tile_data: TileData = tile_map_layer.get_cell_tile_data(tile_map_layer.local_to_map(tile_map_layer.to_local(global_position)))

	return str(tile_data.get_custom_data("material")) if tile_data else FALLBACK_MATERIAL


func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	animation_player.play("attack")


func _on_animation_player_animation_finished(animation_name: String) -> void:
	if animation_name == "attack":
		is_attacking = false
