## Detects player interaction and displays dialogue.
## Attach to Area2D nodes to create dialogue trigger zones.
## Configure dialogue content and positioning options in the inspector.

extends Area2D

@export var activate_instant: bool
@export var only_active_once: bool
@export var dialogue_position: String = "auto"  # "auto", "top", "bottom", "center"
@export var override_dialogue_position: bool
@export var override_position: Vector2
@export var dialogue: Array[DE]

var player_body_in: bool         = false
var has_activated_already: bool  = false
var player_node: CharacterBody2D = null


## Initialize player reference on scene ready
func _ready() -> void:
	for i in get_tree().get_nodes_in_group("player"):
		player_node = i


## Handle input detection for dialogue activation
func _process(_delta: float) -> void:
	if !player_node:
		for i in get_tree().get_nodes_in_group("player"):
			player_node = i
		return

	if !activate_instant and player_body_in:
		if only_active_once and has_activated_already:
			set_process(false)
			return

		if Input.is_action_just_pressed("Interact"):
			_activate_dialogue()
			player_body_in = false


## Activate dialogue through UIManager with configured settings
func _activate_dialogue() -> void:
	if player_node:
		player_node.can_move = false

	has_activated_already = true

	if not UIManager:
		push_error("UIManager not found! Please ensure it is set up in the scene tree.")
		return

	var override_pos: Vector2 = override_position if override_dialogue_position else Vector2.ZERO
	UIManager.show_dialogue(dialogue, dialogue_position, override_pos)


## Handle player entering dialogue area
## @param body: The body that entered the area
func _on_body_entered(body: Node2D) -> void:
	if only_active_once and has_activated_already:
		return
	if body.is_in_group("player"):
		player_body_in = true
		if activate_instant:
			_activate_dialogue()


# Handle player exiting dialogue area
## @param body: The body that exited the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_body_in = false
