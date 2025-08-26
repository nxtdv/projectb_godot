class_name IMaterialProvider
extends RefCounted

## Material Provider Interface
##
## Abstract interface that defines the contract for all material detection providers.
## Each scene type (overworld, dungeon, building) should implement this interface
## to provide scene-specific material detection logic.
##
## Implementation Requirements:
## - Must override get_material_at() method
## - Should return appropriate material strings
## - May override cleanup() for resource management
##
## Supported Material Types:
## - "grass": Default outdoor surface
## - "dirt": Tilled soil or earth paths  
## - "stone": Rocky surfaces or paved areas
## - "water": Liquid surfaces
## - "wood": Indoor flooring or wooden surfaces

## Abstract method to get surface material at world position
## Must be implemented by all concrete provider classes
## @param world_pos: World coordinates to check for surface material
## @return: String identifier for surface material type
func get_material_at(_world_pos: Vector2) -> String:
	push_error("get_material_at() doit être implémenté par la classe enfant")
	return "grass"


## Optional cleanup method for resource management
## Override in concrete implementations if cleanup is needed
func cleanup():
	# Default implementation does nothing
	pass