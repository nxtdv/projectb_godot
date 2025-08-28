extends Node2D

## High-performance seed planting system with visual grid preview for farming games.
## Only allows planting on tilled soil with real-time visual feedback and distance validation.
##
## Features:
## - Visual grid showing plantable areas around player
## - Distance-based interaction validation (32px default)
## - Seed type cycling with up/down arrows
## - Object pooling for optimal performance with large grids
## - Differential sprite updates (only changes what's needed)
## - Color-coded visual feedback (green=plantable, yellow=occupied, red=invalid)
##
## Performance Optimizations:
## - Zero memory allocations during gameplay
## - Precomputed tile offset patterns for range calculations
## - Sprite pooling to avoid create/destroy overhead
## - Batched visual updates with configurable frequency
## - Distance calculations using squared values (avoids sqrt)
##
## Usage:
## ```gdscript
## # Setup in scene
## seed_planter.tilled_soil_layer = farming_layer
## seed_planter.crops_layer = crops_layer
## seed_planter.max_distance = 32.0
## 
## # Configure crops in inspector
## crop_definitions["wheat"] = {
##     "name": "Wheat",
##     "source_id": 0,
##     "atlas_coords": [Vector2i(0,0), Vector2i(1,0)]
## }
## 
## # Player controls: place_object to toggle, arrows to select crop, click to plant
## ```

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
## Dictionary mapping crop IDs to their configuration data
## Each crop should have: name (String), source_id (int), atlas_coords (Array[Vector2i])
@export var crop_definitions: Dictionary = {"carrot":
	{
		"name": "Carrot",
		"source_id": 4,
		"atlas_coords": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 0), Vector2i(4, 1)],
	}}

## Current planting mode state
var planting_mode: bool = false
## List of available crop types for planting
var available_crops: Array[String] = ["carrot"]
## Currently selected crop index
var selected_crop_index: int = 0
## Reference to the player node for distance calculations
var player: Node2D
## Precomputed tile positions within interaction range
var tile_offsets: Array[Vector2i] = []
## Precomputed squared distances for each tile offset (avoids sqrt calculations)
var offset_distances_sq: Array[int] = []
## Maximum interaction range squared for fast distance comparisons
var range_squared: int
## Size of each tile in pixels
var tile_size: int = 16
## Pool of reusable sprites for visual grid (Vector2i -> Sprite2D)
var sprite_pool: Dictionary = {}
## Currently visible tile positions (Vector2i -> bool)
var currently_visible: Dictionary = {}
## Reused array for tracking visibility changes (prevents allocations)
var needs_visibility_update: Array[Vector2i] = []
## Shared texture used by all grid sprites (memory optimization)
var shared_texture: ImageTexture
## Last known player tile position for change detection
var last_player_tile: Vector2i = Vector2i.MAX
## Frame counter for update frequency throttling
var update_counter: int = 0
## Color constants for visual grid feedback
const COLOR_CAN_PLANT: Color = Color(0.2, 0.8, 0.2, 0.6)    # Green = can plant
const COLOR_OCCUPIED: Color  = Color(0.8, 0.8, 0.2, 0.6)     # Yellow = occupied 
const COLOR_NO_SOIL: Color   = Color(0.8, 0.2, 0.2, 0.6)      # Red = no tilled soil


## Initialize seed planter and setup optimization caches
func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	_precompute_all_values()
	_create_shared_resources()


## Precompute all tile offsets and distances within interaction range
## This optimization avoids expensive calculations during runtime
func _precompute_all_values() -> void:
	range_squared = int(max_distance * max_distance)
	var range_in_tiles: int = int(max_distance / tile_size) + 1

	tile_offsets.clear()
	offset_distances_sq.clear()

	# Calculate all valid tile positions within circular range
	for x in range(-range_in_tiles, range_in_tiles + 1):
		for y in range(-range_in_tiles, range_in_tiles + 1):
			var pixel_x: int = x * tile_size
			var pixel_y: int = y * tile_size
			var dist_sq: int = pixel_x * pixel_x + pixel_y * pixel_y

			if dist_sq <= range_squared:
				tile_offsets.append(Vector2i(x, y))
				offset_distances_sq.append(dist_sq)


## Create shared visual resources and initialize reusable arrays
func _create_shared_resources() -> void:
	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	shared_texture = ImageTexture.new()
	shared_texture.set_image(image)

	# Pre-allocate array to avoid runtime allocations
	needs_visibility_update.resize(tile_offsets.size())


## Handle input events for planting mode toggle and crop selection
## @param event: Input event from Godot's input system
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_object"):
		_toggle_planting_mode()
		return

	if not planting_mode:
		return

	# Crop type cycling with arrow keys
	if event.is_action_pressed("ui_up"):
		_cycle_crop(-1)
	elif event.is_action_pressed("ui_down"):
		_cycle_crop(1)

	# Planting and removal actions
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_plant_seed()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_remove_seed()


## Update visual grid when player moves (throttled for performance)
## @param _delta: Time elapsed since last frame (unused)
func _process(_delta: float) -> void:
	if not planting_mode or not player:
		return

	# Throttle updates to reduce CPU usage
	update_counter += 1
	if update_counter % update_frequency != 0:
		return

	_update_range_grid_differential()


## Toggle planting mode on/off with visual feedback
func _toggle_planting_mode() -> void:
	planting_mode = !planting_mode

	if planting_mode:
		var crop_name: String = crop_definitions[available_crops[selected_crop_index]]["name"]
		print("Planting mode ON - Selected: ", crop_name)
		_force_full_update()
	else:
		print("Planting mode OFF")
		_hide_all_sprites_fast()


## Cycle through available crop types
## @param direction: 1 for next crop, -1 for previous crop
func _cycle_crop(direction: int) -> void:
	selected_crop_index = (selected_crop_index + direction) % available_crops.size()
	if selected_crop_index < 0:
		selected_crop_index = available_crops.size() - 1

	var crop_name: String = available_crops[selected_crop_index]
	print("Selected: ", crop_definitions[crop_name]["name"])


## Plant a seed at the mouse cursor position with validation
func _plant_seed() -> void:
	var cell_pos: Vector2i = _get_cell_under_mouse()

	if not _can_interact_at_fast(cell_pos):
		print("Too far from player")
		return

	# Detailed debug information for troubleshooting
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

	# Place the seed tile
	crops_layer.set_cell(cell_pos, crop_def["source_id"], crop_def["atlas_coords"][0])

	# Update visual grid color
	_update_single_sprite_color(cell_pos)

	print("Planted ", crop_def["name"], " at ", cell_pos)


## Remove a seed at the mouse cursor position
func _remove_seed() -> void:
	var cell_pos: Vector2i = _get_cell_under_mouse()

	if not _can_interact_at_fast(cell_pos):
		return

	if not _has_seed_at(cell_pos):
		return

	crops_layer.erase_cell(cell_pos)
	_update_single_sprite_color(cell_pos)

	print("Removed seed at ", cell_pos)


## Check if a position is valid for planting
## @param cell_pos: Grid position to check
## @return: True if planting is allowed at this position
func _can_plant_at(cell_pos: Vector2i) -> bool:
	# Must have tilled soil
	if not _has_tilled_soil_at(cell_pos):
		return false

	# Must not already have a seed
	if _has_seed_at(cell_pos):
		return false

	return true


## Check if there is tilled soil at the given position
## @param cell_pos: Grid position to check
## @return: True if tilled soil exists at this position
func _has_tilled_soil_at(cell_pos: Vector2i) -> bool:
	return tilled_soil_layer.get_cell_source_id(cell_pos) != -1


## Check if there is already a seed planted at the given position
## @param cell_pos: Grid position to check
## @return: True if a seed exists at this position
func _has_seed_at(cell_pos: Vector2i) -> bool:
	return crops_layer.get_cell_source_id(cell_pos) != -1
	

## Update visual grid using differential algorithm (only changes what's needed)
## This is the core performance optimization that enables smooth gameplay with large grids
func _update_range_grid_differential() -> void:
	var current_player_tile: Vector2i = _get_player_tile_pos_fast()

	if current_player_tile == last_player_tile:
		return

	last_player_tile = current_player_tile

	var new_visible: Dictionary = {}
	var update_count: int       = 0

	# Build new visibility set using precomputed offsets
	for i in tile_offsets.size():
		var tile_pos: Vector2i = current_player_tile + tile_offsets[i]
		new_visible[tile_pos] = true

		var was_visible: bool = currently_visible.has(tile_pos)
		if not was_visible:
			needs_visibility_update[update_count] = tile_pos
			update_count += 1

	# Hide sprites that are no longer visible
	for pos in currently_visible:
		if not new_visible.has(pos):
			if pos in sprite_pool:
				sprite_pool[pos].visible = false

	# Show/update sprites that are now visible
	for i in update_count:
		var pos: Vector2i    = needs_visibility_update[i]
		var sprite: Sprite2D = _get_or_create_sprite_fast(pos)
		sprite.visible = true
		sprite.modulate = _get_tile_color_fast(pos)

	# Update colors of existing visible sprites
	for pos in currently_visible:
		if new_visible.has(pos) and pos in sprite_pool:
			sprite_pool[pos].modulate = _get_tile_color_fast(pos)

	currently_visible = new_visible


## Force complete rebuild of the visual grid
func _force_full_update() -> void:
	last_player_tile = Vector2i.MAX
	currently_visible.clear()
	_update_range_grid_differential()


## Get or create a sprite from the object pool
## @param tile_pos: Grid position for the sprite
## @return: Reusable Sprite2D from the pool
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


## Determine the appropriate color for a grid tile based on its state
## @param tile_pos: Grid position to check
## @return: Color representing the tile's planting state
func _get_tile_color_fast(tile_pos: Vector2i) -> Color:
	# Already has a seed planted
	if _has_seed_at(tile_pos):
		return COLOR_OCCUPIED

	# Has tilled soil = can plant
	if _has_tilled_soil_at(tile_pos):
		return COLOR_CAN_PLANT

	# No tilled soil = cannot plant
	return COLOR_NO_SOIL


## Update the color of a single sprite in the visual grid
## @param tile_pos: Grid position of the sprite to update
func _update_single_sprite_color(tile_pos: Vector2i) -> void:
	if tile_pos in sprite_pool:
		sprite_pool[tile_pos].modulate = _get_tile_color_fast(tile_pos)


## Get player position in tile coordinates with sprite offset compensation
## @return: Player's current tile position
func _get_player_tile_pos_fast() -> Vector2i:
	var player_local: Vector2  = crops_layer.to_local(player.global_position)
	var sprite_offset: Vector2 = Vector2(0, -16)  # Adjust based on your player's sprite offset
	var corrected_pos: Vector2 = player_local + sprite_offset
	return crops_layer.local_to_map(corrected_pos)


## Fast distance check using precomputed squared values
## @param cell_pos: Grid position to check
## @return: True if position is within interaction range
func _can_interact_at_fast(cell_pos: Vector2i) -> bool:
	if not player:
		return false

	var player_tile: Vector2i = _get_player_tile_pos_fast()
	var offset: Vector2i      = cell_pos - player_tile
	var pixel_offset_x: int   = offset.x * tile_size
	var pixel_offset_y: int   = offset.y * tile_size
	var dist_sq: int          = pixel_offset_x * pixel_offset_x + pixel_offset_y * pixel_offset_y

	return dist_sq <= range_squared


## Convert mouse position to grid coordinates
## @return: Grid position under the mouse cursor
func _get_cell_under_mouse() -> Vector2i:
	var mouse_pos: Vector2 = crops_layer.get_local_mouse_position()
	return crops_layer.local_to_map(mouse_pos)


## Hide all sprites in the visual grid (used when exiting planting mode)
func _hide_all_sprites_fast() -> void:
	for sprite in sprite_pool.values():
		sprite.visible = false
	currently_visible.clear()


## Cleanup resources when node is destroyed
func _exit_tree() -> void:
	for sprite in sprite_pool.values():
		if is_instance_valid(sprite):
			sprite.queue_free()

	sprite_pool.clear()
	currently_visible.clear()
	tile_offsets.clear()
	offset_distances_sq.clear()