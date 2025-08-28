# seed_planter.gd - Plantation avec grille de preview optimisée
extends Node2D

## Optimized Seed Planter with Visual Grid
##
## Allows planting seeds only on tilled soil with visual grid preview.
## Shows plantable areas around player within interaction range.

@export_group("Tile Layers")
## Tilled soil layer to check for plantable areas
@export var tilled_soil_layer: TileMapLayer
## Layer where seeds will be placed
@export var crops_layer: TileMapLayer
@export_group("Interaction Settings")
## Maximum planting distance in pixels
@export var max_distance: float = 32.0
## Update frequency divider (1=every frame, 2=every other frame, etc)
@export var update_frequency: int = 1

@export_group("Crop Configuration")
@export var crop_definitions: Dictionary = {"carrot":
	{
		"name": "Carrot",
		"source_id": 4,
		"atlas_coords": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(4, 1)],
	}}

# État
var planting_mode: bool            = false
var available_crops: Array[String] = ["carrot"]
var selected_crop_index: int       = 0
var player: Node2D
# Système de grille optimisé
var tile_offsets: Array[Vector2i]   = []
var offset_distances_sq: Array[int] = []
var range_squared: int
var tile_size: int                  = 16
# Sprite management
var sprite_pool: Dictionary                  = {}               # Vector2i -> Sprite2D
var currently_visible: Dictionary            = {}         # Vector2i -> bool
var needs_visibility_update: Array[Vector2i] = []
# Resources partagées
var shared_texture: ImageTexture
var last_player_tile: Vector2i = Vector2i.MAX
var update_counter: int        = 0
# Couleurs pour la grille
const COLOR_CAN_PLANT: Color = Color(0.2, 0.8, 0.2, 0.6)    # Vert = peut planter
const COLOR_OCCUPIED: Color  = Color(0.8, 0.8, 0.2, 0.6)     # Jaune = occupé 
const COLOR_NO_SOIL: Color   = Color(0.8, 0.2, 0.2, 0.6)      # Rouge = pas de terre labourée


func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	_precompute_all_values()
	_create_shared_resources()


func _precompute_all_values() -> void:
	range_squared = int(max_distance * max_distance)
	var range_in_tiles: int = int(max_distance / tile_size) + 1

	tile_offsets.clear()
	offset_distances_sq.clear()

	# Précalcule tous les offsets valides
	for x in range(-range_in_tiles, range_in_tiles + 1):
		for y in range(-range_in_tiles, range_in_tiles + 1):
			var pixel_x: int = x * tile_size
			var pixel_y: int = y * tile_size
			var dist_sq: int = pixel_x * pixel_x + pixel_y * pixel_y

			if dist_sq <= range_squared:
				tile_offsets.append(Vector2i(x, y))
				offset_distances_sq.append(dist_sq)


func _create_shared_resources() -> void:
	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	shared_texture = ImageTexture.new()
	shared_texture.set_image(image)

	needs_visibility_update.resize(tile_offsets.size())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_object"):
		_toggle_planting_mode()
		return

	if not planting_mode:
		return

	# Navigation des graines
	if event.is_action_pressed("ui_up"):
		_cycle_crop(-1)
	elif event.is_action_pressed("ui_down"):
		_cycle_crop(1)

	# Plantation
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_plant_seed()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_remove_seed()


func _process(_delta: float) -> void:
	if not planting_mode or not player:
		return

	# Throttle des updates
	update_counter += 1
	if update_counter % update_frequency != 0:
		return

	_update_range_grid_differential()


func _toggle_planting_mode() -> void:
	planting_mode = !planting_mode

	if planting_mode:
		var crop_name: String = crop_definitions[available_crops[selected_crop_index]]["name"]
		print("Planting mode ON - Selected: ", crop_name)
		_force_full_update()
	else:
		print("Planting mode OFF")
		_hide_all_sprites_fast()


func _cycle_crop(direction: int) -> void:
	selected_crop_index = (selected_crop_index + direction) % available_crops.size()
	if selected_crop_index < 0:
		selected_crop_index = available_crops.size() - 1

	var crop_name: String = available_crops[selected_crop_index]
	print("Selected: ", crop_definitions[crop_name]["name"])


func _plant_seed() -> void:
	var cell_pos: Vector2i = _get_cell_under_mouse()

	if not _can_interact_at_fast(cell_pos):
		print("Too far from player")
		return

	# Debug détaillé
	var has_soil: bool = _has_tilled_soil_at(cell_pos)
	var has_seed: bool = _has_seed_at(cell_pos)
	var soil_id: int   = tilled_soil_layer.get_cell_source_id(cell_pos)
	var seed_id: int   = crops_layer.get_cell_source_id(cell_pos)

	print("Position: ", cell_pos)
	print("Soil layer ID: ", soil_id, " (has_soil: ", has_soil, ")")
	print("Crop layer ID: ", seed_id, " (has_seed: ", has_seed, ")")

	if not _can_plant_at(cell_pos):
		print("Cannot plant here")
		return

	var crop_name: String    = available_crops[selected_crop_index]
	var crop_def: Dictionary = crop_definitions[crop_name]

	# Place la graine
	crops_layer.set_cell(cell_pos, crop_def["source_id"], crop_def["atlas_coords"][0])

	# Met à jour la couleur de la grille
	_update_single_sprite_color(cell_pos)

	print("Planted ", crop_def["name"], " at ", cell_pos)


func _remove_seed() -> void:
	var cell_pos: Vector2i = _get_cell_under_mouse()

	if not _can_interact_at_fast(cell_pos):
		return

	if not _has_seed_at(cell_pos):
		return

	crops_layer.erase_cell(cell_pos)
	_update_single_sprite_color(cell_pos)

	print("Removed seed at ", cell_pos)


func _can_plant_at(cell_pos: Vector2i) -> bool:
	# Doit avoir de la terre labourée
	if not _has_tilled_soil_at(cell_pos):
		return false

	# Ne doit pas déjà avoir une graine
	if _has_seed_at(cell_pos):
		return false

	return true


func _has_tilled_soil_at(cell_pos: Vector2i) -> bool:
	return tilled_soil_layer.get_cell_source_id(cell_pos) != -1


func _has_seed_at(cell_pos: Vector2i) -> bool:
	return crops_layer.get_cell_source_id(cell_pos) != -1


# ============================================================================
# SYSTÈME DE GRILLE IDENTIQUE AU FIELD CURSOR
# ============================================================================

func _update_range_grid_differential() -> void:
	var current_player_tile: Vector2i = _get_player_tile_pos_fast()

	if current_player_tile == last_player_tile:
		return

	last_player_tile = current_player_tile

	var new_visible: Dictionary = {}
	var update_count: int       = 0

	for i in tile_offsets.size():
		var tile_pos: Vector2i = current_player_tile + tile_offsets[i]
		new_visible[tile_pos] = true

		var was_visible: bool = currently_visible.has(tile_pos)
		if not was_visible:
			needs_visibility_update[update_count] = tile_pos
			update_count += 1

	# Masque les sprites non visibles
	for pos in currently_visible:
		if not new_visible.has(pos):
			if pos in sprite_pool:
				sprite_pool[pos].visible = false

	# Affiche/met à jour les sprites visibles
	for i in update_count:
		var pos: Vector2i    = needs_visibility_update[i]
		var sprite: Sprite2D = _get_or_create_sprite_fast(pos)
		sprite.visible = true
		sprite.modulate = _get_tile_color_fast(pos)

	# Met à jour les couleurs des sprites existants
	for pos in currently_visible:
		if new_visible.has(pos) and pos in sprite_pool:
			sprite_pool[pos].modulate = _get_tile_color_fast(pos)

	currently_visible = new_visible


func _force_full_update() -> void:
	last_player_tile = Vector2i.MAX
	currently_visible.clear()
	_update_range_grid_differential()


func _get_or_create_sprite_fast(tile_pos: Vector2i) -> Sprite2D:
	if tile_pos in sprite_pool:
		return sprite_pool[tile_pos]

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = shared_texture
	sprite.scale = Vector2(tile_size, tile_size)

	var world_pos: Vector2 = crops_layer.map_to_local(tile_pos)
	sprite.position = world_pos
	sprite.centered = true

	add_child(sprite)
	sprite_pool[tile_pos] = sprite

	return sprite


func _get_tile_color_fast(tile_pos: Vector2i) -> Color:
	# Déjà une graine plantée
	if _has_seed_at(tile_pos):
		return COLOR_OCCUPIED

	# Terre labourée = peut planter
	if _has_tilled_soil_at(tile_pos):
		return COLOR_CAN_PLANT

	# Pas de terre labourée = ne peut pas planter
	return COLOR_NO_SOIL


func _update_single_sprite_color(tile_pos: Vector2i) -> void:
	if tile_pos in sprite_pool:
		sprite_pool[tile_pos].modulate = _get_tile_color_fast(tile_pos)


func _get_player_tile_pos_fast() -> Vector2i:
	var player_local: Vector2  = crops_layer.to_local(player.global_position)
	var sprite_offset: Vector2 = Vector2(0, -16)  # Ajuste selon ton player
	var corrected_pos: Vector2 = player_local + sprite_offset
	return crops_layer.local_to_map(corrected_pos)


func _can_interact_at_fast(cell_pos: Vector2i) -> bool:
	if not player:
		return false

	var player_tile: Vector2i = _get_player_tile_pos_fast()
	var offset: Vector2i      = cell_pos - player_tile
	var pixel_offset_x: int   = offset.x * tile_size
	var pixel_offset_y: int   = offset.y * tile_size
	var dist_sq: int          = pixel_offset_x * pixel_offset_x + pixel_offset_y * pixel_offset_y

	return dist_sq <= range_squared


func _get_cell_under_mouse() -> Vector2i:
	var mouse_pos: Vector2 = crops_layer.get_local_mouse_position()
	return crops_layer.local_to_map(mouse_pos)


func _hide_all_sprites_fast() -> void:
	for sprite in sprite_pool.values():
		sprite.visible = false
	currently_visible.clear()


func _exit_tree() -> void:
	for sprite in sprite_pool.values():
		if is_instance_valid(sprite):
			sprite.queue_free()

	sprite_pool.clear()
	currently_visible.clear()
	tile_offsets.clear()
	offset_distances_sq.clear()
