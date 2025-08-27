# seed_planter.gd - Version simplifiée sans BlockData
extends Node2D

@export var crops_layer: TileMapLayer
@export var max_distance: float = 64.0

@export var crop_definitions: Dictionary = {
											   "carrot": {
												   "name": "Carrot",
												   "source_id": 4,
												   "atlas_coords": [Vector2i(0, 1)],
											   }
										   }

var available_crops: Array[String] = ["carrot"]
var selected_crop_index: int       = 0
var planting_mode: bool            = false
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_object"):
		planting_mode = !planting_mode
		print("Planting mode: ", "ON" if planting_mode else "OFF")
		return

	if not planting_mode:
		return

	if event.is_action_pressed("ui_up"):
		_cycle_crop(-1)
	elif event.is_action_pressed("ui_down"):
		_cycle_crop(1)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_plant_seed()


func _cycle_crop(direction: int) -> void:
	selected_crop_index = (selected_crop_index + direction) % available_crops.size()
	if selected_crop_index < 0:
		selected_crop_index = available_crops.size() - 1

	var crop_name: String = available_crops[selected_crop_index]
	print("Selected: ", crop_definitions[crop_name]["name"])


func _plant_seed() -> void:
	var cell_pos: Vector2i = _get_cell_under_mouse()
	if not _can_interact_at(cell_pos):
		return

	print("SOURCE ", crops_layer.get_cell_source_id(cell_pos))

	var crop_name: String = available_crops[selected_crop_index]
	var crop_def          = crop_definitions[crop_name]

	print(crop_def)

	# Debug: vérifie les paramètres
	print("Setting cell: pos=", cell_pos, " source_id=", crop_def["source_id"], " atlas_coord=", crop_def["atlas_coords"][0])

	crops_layer.set_cell(cell_pos, crop_def["source_id"], crop_def["atlas_coords"][0])

	# Vérifie si ça a marché
	var placed_id: int = crops_layer.get_cell_source_id(cell_pos)
	print("Placed source_id: ", placed_id)


func _get_cell_under_mouse() -> Vector2i:
	var mouse_pos: Vector2 = crops_layer.get_local_mouse_position()
	return crops_layer.local_to_map(mouse_pos)


func _can_interact_at(cell_pos: Vector2i) -> bool:
	if not player:
		return true

	var world_pos: Vector2    = crops_layer.map_to_local(cell_pos)
	var player_local: Vector2 = crops_layer.to_local(player.global_position)
	return world_pos.distance_to(player_local) <= max_distance
