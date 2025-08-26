class_name OverworldMaterialProvider
extends IMaterialProvider

## Overworld Material Provider
##
## Material provider specialized for overworld/farm scenes with multiple tile layers.
## Handles terrain detection with priority system: farming modifications override base terrain.
##
## Features:
## - Layer-based priority system (farming > terrain)
## - Position caching for performance optimization
## - Custom data material detection from tilesets
## - Fallback to grass for undefined materials
##
## Layer Priority:
## 1. Farming layer (tilled soil, crops)
## 2. Base terrain layer (grass, stone, water)

## Reference to the base terrain TileMapLayer
var terrain_layer: TileMapLayer
## Reference to the farming modifications TileMapLayer
var farming_layer: TileMapLayer
## Cache for the last checked position to avoid redundant calculations
var _last_position: Vector2i = Vector2i.MAX
## Cached material result for the last position
var _cached_material: String = "grass"

## Initialize the provider with required tile layers
## @param terrain: Base terrain TileMapLayer containing ground materials
## @param farming: Optional farming TileMapLayer for soil modifications
func _init(terrain: TileMapLayer, farming: TileMapLayer = null):
	terrain_layer = terrain
	farming_layer = farming

## Determines surface material at world position using layer priority system
## @param world_pos: World position to check
## @return: Surface material string ("grass", "dirt", "stone", etc.)
func get_material_at(world_pos: Vector2) -> String:
	if not terrain_layer:
		return "grass"

	var tile_pos: Vector2i = terrain_layer.local_to_map(terrain_layer.to_local(world_pos))

	# Use cached result if checking same position
	if tile_pos == _last_position:
		return _cached_material

	_last_position = tile_pos

	# Priority 1: Farming layer (soil modifications)
	if farming_layer:
		var farming_tile_id: int = farming_layer.get_cell_source_id(tile_pos)
		if farming_tile_id != -1:
			_cached_material = "dirt"
			return _cached_material

	# Priority 2: Base terrain layer
	var tile_data: TileData = terrain_layer.get_cell_tile_data(tile_pos)
	if tile_data and tile_data.get_custom_data("material"):
		_cached_material = str(tile_data.get_custom_data("material"))
		return _cached_material

	# Fallback to grass
	_cached_material = "grass"
	return _cached_material