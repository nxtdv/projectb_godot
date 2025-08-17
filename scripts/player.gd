extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var speed_velocity = 300.0

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Up", "Down")
	
	velocity = input_vector.normalized() * speed_velocity

	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

	# Applique le mouvement
	move_and_slide()
