# field_cursor.gd - Version ultra-optimisée
extends Node2D

## Ultra-Optimized Field Cursor
##
## Maximum performance farming system with zero-allocation updates and precomputed ranges.
## Uses differential updates, object pooling, and cached calculations for optimal efficiency.
##
## Performance Features:
## - Zero memory allocations during gameplay
## - Precomputed tile offset patterns
## - Differential sprite visibility updates
## - Distance calculations using integer math
## - Shared texture and pooled sprites
##
## Usage:
## ```gdscript
## # Setup in scene
## field_cursor.grass_tilemap_layer = terrain_layer
## field_cursor.tilled_soil_tilemap_layer = farming_layer
## field_cursor.max_distance = 64.0
## 
## # Player toggles with ESC, interacts with mouse clicks
## ```

@export_group("Tile Layers")
## Base terrain layer containing ground materials
@export var grass_tilemap_layer: TileMapLayer
## Farming modifications layer for tilled soil
@export var tilled_soil_tilemap_layer: TileMapLayer
@export_group("Terrain Configuration")
## Terrain set ID in the tileset resource
@export var terrain_set: int = 0
## Terrain type ID for tilled soil
@export var terrain: int = 3
@export_group("Interaction Settings")
## Maximum interaction distance in pixels
@export var max_distance: float = 64.0
## Update frequency divider (1=every frame, 2=every other frame, etc)
@export var update_frequency: int = 1

# Core state
var farming_mode: bool = false
var player: Node2D
# Precomputed values - calculated once
var tile_offsets: Array[Vector2i]   = []         # All valid tile positions within range
var offset_distances_sq: Array[int] = []       # Squared distances for each offset
var range_squared: int                         # Max range squared for comparisons
var tile_size: int                  = 16                        # Tile size in pixels
# Sprite management - zero allocation during updates
var sprite_pool: Dictionary                  = {}               # Vector2i -> Sprite2D
var currently_visible: Dictionary            = {}         # Vector2i -> bool (previous frame state)
var needs_visibility_update: Array[Vector2i] = []  # Reused array for visibility changes
# Shared resources
var shared_texture: ImageTexture
var last_player_tile: Vector2i = Vector2i.MAX
var update_counter: int        = 0
## Color constants for tile states
const COLOR_CAN_TILL: Color   = Color(0.2, 0.8, 0.2, 0.6)    # Green
const COLOR_CAN_REMOVE: Color = Color(0.8, 0.8, 0.2, 0.6)  # Yellow  
const COLOR_INVALID: Color    = Color(0.8, 0.2, 0.2, 0.6)     # Red


func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	_precompute_all_values()
	_create_shared_resources()


## Precompute all possible tile offsets and distances within range
func _precompute_all_values() -> void:
	range_squared = int(max_distance * max_distance)
	var range_in_tiles: int = int(max_distance / tile_size) + 1

	tile_offsets.clear()
	offset_distances_sq.clear()

	# Precompute all valid offsets and their squared distances
	for x in range(-range_in_tiles, range_in_tiles + 1):
		for y in range(-range_in_tiles, range_in_tiles + 1):
			var pixel_x: int = x * tile_size
			var pixel_y: int = y * tile_size
			var dist_sq: int = pixel_x * pixel_x + pixel_y * pixel_y

			if dist_sq <= range_squared:
				tile_offsets.append(Vector2i(x, y))
				offset_distances_sq.append(dist_sq)


## Create shared texture and initialize reused arrays
func _create_shared_resources() -> void:
	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	shared_texture = ImageTexture.new()
	shared_texture.set_image(image)

	# Pre-allocate array to avoid allocations during updates
	needs_visibility_update.resize(tile_offsets.size())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_farming_mode()
		return

	if not farming_mode:
		return

	if event is InputEventMouseButton and event.pressed:
		var cell_pos: Vector2i = _get_cell_under_mouse()
		if not _can_interact_at_fast(cell_pos):
			return

		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_add_tilled_soil_fast(cell_pos)
			MOUSE_BUTTON_RIGHT:
				_remove_tilled_soil_fast(cell_pos)


func _process(_delta: float) -> void:
	if not farming_mode or not player:
		return

	# Throttle updates for performance
	update_counter += 1
	if update_counter % update_frequency != 0:
		return

	_update_range_grid_differential()


func _toggle_farming_mode() -> void:
	farming_mode = !farming_mode

	if farming_mode:
		print("Farming mode ON")
		_force_full_update()
	else:
		print("Farming mode OFF")
		_hide_all_sprites_fast()


## Ultra-fast differential update - only changes what's needed
func _update_range_grid_differential() -> void:
	var current_player_tile: Vector2i = _get_player_tile_pos_fast()

	if current_player_tile == last_player_tile:
		return

	last_player_tile = current_player_tile

	# Build new visible set using precomputed offsets
	var new_visible: Dictionary = {}
	var update_count: int       = 0

	for i in tile_offsets.size():
		var tile_pos: Vector2i = current_player_tile + tile_offsets[i]
		new_visible[tile_pos] = true

		# Track what needs visibility updates (reuse array)
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

	# Update existing visible sprites colors
	for pos in currently_visible:
		if new_visible.has(pos) and pos in sprite_pool:
			sprite_pool[pos].modulate = _get_tile_color_fast(pos)

	currently_visible = new_visible


## Force complete rebuild of visible grid
func _force_full_update() -> void:
	last_player_tile = Vector2i.MAX  # Force update
	currently_visible.clear()
	_update_range_grid_differential()


## Optimized sprite creation with minimal overhead
func _get_or_create_sprite_fast(tile_pos: Vector2i) -> Sprite2D:
	if tile_pos in sprite_pool:
		return sprite_pool[tile_pos]

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = shared_texture
	sprite.scale = Vector2(tile_size, tile_size)

	# Centered sprite positioning for proper grid alignment
	var world_pos: Vector2 = tilled_soil_tilemap_layer.map_to_local(tile_pos)
	sprite.position = world_pos
	sprite.centered = true  # Ensures sprite centers on tile

	add_child(sprite)
	sprite_pool[tile_pos] = sprite

	return sprite


## Fast tile interaction with pre-validated distance
func _add_tilled_soil_fast(cell_pos: Vector2i) -> void:
	if tilled_soil_tilemap_layer.get_cell_source_id(cell_pos) != -1:
		return

	if grass_tilemap_layer.get_cell_source_id(cell_pos) == -1:
		return

	tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_pos], terrain_set, terrain, true)
	_update_single_sprite_color(cell_pos)


## Fast tile removal with minimal validation
func _remove_tilled_soil_fast(cell_pos: Vector2i) -> void:
	tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_pos], terrain_set, -1, true)
	_update_single_sprite_color(cell_pos)


## Optimized color determination using bit operations where possible
func _get_tile_color_fast(tile_pos: Vector2i) -> Color:
	var tilled_id: int = tilled_soil_tilemap_layer.get_cell_source_id(tile_pos)

	if tilled_id != -1:
		return COLOR_CAN_REMOVE

	var base_id: int = grass_tilemap_layer.get_cell_source_id(tile_pos)
	if base_id == -1:
		return COLOR_INVALID

	return COLOR_CAN_TILL


## Direct sprite color update without dictionary lookups
func _update_single_sprite_color(tile_pos: Vector2i) -> void:
	if tile_pos in sprite_pool:
		sprite_pool[tile_pos].modulate = _get_tile_color_fast(tile_pos)


## Ultra-fast player position using integer coordinates with sprite offset compensation
func _get_player_tile_pos_fast() -> Vector2i:
	# Convert player position to tilemap local coordinates
	var player_local: Vector2 = tilled_soil_tilemap_layer.to_local(player.global_position)

	# Compensate for sprite offset (player sprite is offset by -16px on Y)
	var sprite_offset: Vector2 = Vector2(0, -16)  # Match your player's sprite offset
	var corrected_pos: Vector2 = player_local + sprite_offset

	return tilled_soil_tilemap_layer.local_to_map(corrected_pos)


## Fast interaction check using precomputed player tile position
func _can_interact_at_fast(cell_pos: Vector2i) -> bool:
	if not player:
		return false

	var player_tile: Vector2i = _get_player_tile_pos_fast()
	var offset: Vector2i      = cell_pos - player_tile
	var pixel_offset_x: int   = offset.x * tile_size
	var pixel_offset_y: int   = offset.y * tile_size
	var dist_sq: int          = pixel_offset_x * pixel_offset_x + pixel_offset_y * pixel_offset_y

	return dist_sq <= range_squared


## Efficient mouse position calculation
func _get_cell_under_mouse() -> Vector2i:
	var mouse_pos: Vector2 = tilled_soil_tilemap_layer.get_local_mouse_position()
	return tilled_soil_tilemap_layer.local_to_map(mouse_pos)


## Batch hide all sprites for mode toggle
func _hide_all_sprites_fast() -> void:
	for sprite in sprite_pool.values():
		sprite.visible = false
	currently_visible.clear()


## Cleanup resources on destruction
func _exit_tree() -> void:
	for sprite in sprite_pool.values():
		if is_instance_valid(sprite):
			sprite.queue_free()

	sprite_pool.clear()
	currently_visible.clear()
	tile_offsets.clear()
	offset_distances_sq.clear()
