## Singleton for managing game UI.
## Handles the display of dialogues and maintains a dedicated UI canvas layer.
## This script should be set as an AutoLoad in the project settings.

extends Node

const DialogueSystemPreload: PackedScene = preload("res://scenes/dialogue_system.tscn")
var ui_canvas_layer: CanvasLayer         = null
var current_dialogue                     = null


## Initializes the UI canvas layer when the game starts.
## The layer is created once and added to the current scene.
func _ready():
	ui_canvas_layer = CanvasLayer.new()
	ui_canvas_layer.name = "UI"
	ui_canvas_layer.layer = 100
	get_tree().current_scene.add_child(ui_canvas_layer)


## Display a dialogue with automatic or manual positioning
## @param dialogue_data: Array of dialogue elements to display
## @param position_preference: "auto", "top", "bottom", or "center"
## @param override_pos: Manual position override (Vector2.ZERO for automatic)
func show_dialogue(dialogue_data: Array, position_preference: String = "auto", override_pos: Vector2 = Vector2.ZERO):
	if current_dialogue:
		current_dialogue.queue_free()
		current_dialogue = null

	current_dialogue = DialogueSystemPreload.instantiate()
	current_dialogue.dialogue = dialogue_data

	var dialogue_position: Vector2 = _calculate_dialogue_position(position_preference, override_pos)
	current_dialogue.global_position = dialogue_position

	ui_canvas_layer.add_child(current_dialogue)


## Calculate optimal dialogue position based on player location and preferences
## @param preference: Position preference string
## @param override_pos: Manual position override
## @return: Vector2 position for dialogue placement
func _calculate_dialogue_position(preference: String, override_pos: Vector2) -> Vector2:
	if override_pos != Vector2.ZERO:
		return override_pos

	var viewport: Viewport     = get_viewport()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var camera: Camera2D       = viewport.get_camera_2d()

	if !camera:
		return Vector2(viewport_size.x / 2, viewport_size.y - 100)

	var camera_center: Vector2 = camera.get_screen_center_position()
	var player: Node           = get_tree().get_first_node_in_group("player")

	match preference:
		"top":
			return Vector2(viewport_size.x / 2, 80)
		"bottom":
			return Vector2(viewport_size.x / 2, viewport_size.y - 80)
		"center":
			return Vector2(viewport_size.x / 2, viewport_size.y / 2)
		_: # "auto"
			if player:
				if player.global_position.y > camera_center.y:
					return Vector2(viewport_size.x / 2, 80)
				else:
					return Vector2(viewport_size.x / 2, viewport_size.y - 80)
			else:
				return Vector2(viewport_size.x / 2, viewport_size.y - 80)


## Hide the currently active dialogue
func hide_dialogue():
	if current_dialogue:
		current_dialogue.queue_free()
		current_dialogue = null


## Check if a dialogue is currently being displayed
## @return: true if dialogue is active, false otherwise
func is_dialogue_active() -> bool:
	return current_dialogue != null