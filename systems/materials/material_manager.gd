extends Node

## Material Manager
##
## Central manager for handling surface material detection across different scene types.
## Uses a provider pattern to delegate material detection to scene-specific implementations.
##
## Features:
## - Automatic provider switching when changing scenes
## - Fallback material when no provider is configured
## - Provider cleanup to prevent memory leaks
## - Debug logging for provider changes
##
## Usage:
## ```gdscript
## # In scene setup
## var provider = OverworldMaterialProvider.new(terrain_layer, farming_layer)
## MaterialManager.set_material_provider(provider)
## 
## # In player code
## var material = MaterialManager.get_material_at_position(player.global_position)
## ```

## Currently active material provider
var current_provider: IMaterialProvider
## Previous provider for cleanup purposes
var previous_provider: IMaterialProvider


## Sets a new material provider and cleans up the previous one
## @param provider: The new IMaterialProvider to use for material detection
func set_material_provider(provider: IMaterialProvider):
	if previous_provider:
		previous_provider.cleanup()
	previous_provider = current_provider
	current_provider = provider
	print("Material provider changé: ", provider.get_script().get_global_name())


## Gets the surface material at a specific world position
## @param world_pos: World position to check for material type
## @return: String representing the surface material ("grass", "dirt", "stone", etc.)
func get_material_at_position(world_pos: Vector2) -> String:
	if current_provider:
		return current_provider.get_material_at(world_pos)

	push_warning("Aucun material provider configuré")
	return "grass"