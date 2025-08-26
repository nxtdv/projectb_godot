extends Node

var current_provider: IMaterialProvider
var previous_provider: IMaterialProvider


func set_material_provider(provider: IMaterialProvider):
	if previous_provider:
		previous_provider.cleanup()
	previous_provider = current_provider
	current_provider = provider
	print("Material provider changé: ", provider.get_script().get_global_name())


func get_material_at_position(world_pos: Vector2) -> String:
	if current_provider:
		return current_provider.get_material_at(world_pos)

	push_warning("Aucun material provider configuré")
	return "grass"
