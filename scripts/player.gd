extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const WALK_SPEED: float                        = 100.0
const SPRINT_SPEED: float                      = 300.0


func _physics_process(_delta: float) -> void:
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
