extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_area: Area2D = $DialogueArea2D

var is_interacting: bool = false
signal interaction_finished


func _ready() -> void:
	animated_sprite.play("idle")

	if not dialogue_area.body_entered.is_connected(_on_dialogue_area_body_entered):
		dialogue_area.body_entered.connect(_on_dialogue_area_body_entered)
	if not dialogue_area.body_exited.is_connected(_on_dialogue_area_body_exited):
		dialogue_area.body_exited.connect(_on_dialogue_area_body_exited)


func _on_dialogue_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		start_interaction()


func _on_dialogue_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		end_interaction()


func start_interaction() -> void:
	if not is_interacting:
		is_interacting = true
		animated_sprite.play("interacting_entry")
		await animated_sprite.animation_finished
		animated_sprite.play("interacting_loop")


func end_interaction() -> void:
	if is_interacting:
		is_interacting = false
		animated_sprite.play("interacting_rest")
		await animated_sprite.animation_finished
		animated_sprite.play("idle")
		interaction_finished.emit()
		
