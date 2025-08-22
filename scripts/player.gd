extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const WALK_SPEED: float                        = 100.0
const SPRINT_SPEED: float                      = 300.0
var is_attacking: bool                         = false
var can_move: bool                             = true


func _ready() -> void:
	add_to_group("player")
	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Attack") and not is_attacking and can_move:
		_start_attack()
		return

	# If the player is attacking, we don't process movement
	if is_attacking:
		return

	# Check if the player can move
	if not can_move:
		velocity = Vector2.ZERO
		animation_player.play("idle")
		move_and_slide()
		return

	var input_vector: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var is_sprinting: bool    = Input.is_action_pressed("Sprint")
	var current_speed: float  = SPRINT_SPEED if is_sprinting else WALK_SPEED

	# Apply velocity
	velocity = input_vector.normalized() * current_speed

	# Flip sprite
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

	# Play animations
	if input_vector == Vector2.ZERO:
		animation_player.play("idle")
	else:
		if is_sprinting:
			animation_player.play("sprint")
		else:
			animation_player.play("walk")

	move_and_slide()


func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO  # We stop moving when attacking
	animation_player.play("attack")


func _on_animation_player_animation_finished(animation_name: String) -> void:
	if animation_name == "attack":
		is_attacking = false
