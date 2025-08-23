# fps_counter.gd (autoload)
extends CanvasLayer

var label: Label

func _ready() -> void:
	label = Label.new()
	add_child(label)
	
	label.position = Vector2(10, 10)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.z_index = 2000

func _process(_delta: float) -> void:
	var fps: int = round(Engine.get_frames_per_second())
	label.text = "FPS: %d" % fps
