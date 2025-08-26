class_name IMaterialProvider
extends RefCounted

func get_material_at(_world_pos: Vector2) -> String:
	push_error("get_material_at() doit être implémenté par la classe enfant")
	return "grass"
