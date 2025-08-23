extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const WALK_SPEED: float                        = 100.0
const SPRINT_SPEED: float                      = 300.0
const STEP_INTERVAL_WALK: float                = 0.6
const STEP_INTERVAL_SPRINT: float              = 0.3
var is_attacking: bool                         = false
var can_move: bool                             = true
var tilemap: TileMapLayer
var step_timer: float                          = 0.0


func _ready() -> void:
	add_to_group("player")
	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)

	tilemap = get_tree().get_first_node_in_group("tilemap")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Attack") and not is_attacking and can_move:
		_start_attack()
		return

	if is_attacking or not can_move:
		velocity = Vector2.ZERO
		animation_player.play("idle")
		move_and_slide()
		return

	var input_vector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var is_sprinting: bool    = Input.is_action_pressed("Sprint")
	var current_speed: float  = SPRINT_SPEED if is_sprinting else WALK_SPEED

	velocity = input_vector.normalized() * current_speed

	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

	if input_vector == Vector2.ZERO:
		animation_player.play("idle")
		step_timer = 0.0
	else:
		if is_sprinting:
			animation_player.play("sprint")
			handle_footsteps(delta, true)
		else:
			animation_player.play("walk")
			handle_footsteps(delta, false)

	move_and_slide()


func handle_footsteps(delta: float, is_running: bool):
	var step_interval: float = STEP_INTERVAL_SPRINT if is_running else STEP_INTERVAL_WALK
	step_timer += delta

	if step_timer >= step_interval:
		play_footstep_sound(is_running)
		step_timer = 0.0


func play_footstep_sound(is_running: bool):
	var surface_material: String = get_current_material()

	if is_running:
		AudioManager.play_run_sound(surface_material, global_position)
	else:
		AudioManager.play_walk_sound(surface_material, global_position)


func get_current_material() -> String:
	if not tilemap:
		return "grass"

	var tile_coords: Vector2i = tilemap.local_to_map(tilemap.to_local(global_position))
	var tile_data: TileData   = tilemap.get_cell_tile_data(tile_coords)

	if tile_data:
		var custom_material = tile_data.get_custom_data("material")
		if custom_material != null:
			return str(custom_material)

	return "grass"


func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	animation_player.play("attack")


func _on_animation_player_animation_finished(animation_name: String) -> void:
	if animation_name == "attack":
		is_attacking = false
