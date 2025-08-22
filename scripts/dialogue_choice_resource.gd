extends DE
class_name DialogueChoice

@export_multiline var text: String
@export var choice_text: Array[String]
@export var choice_function_call: Array[DialogueFunction]

@export_range(0.1, 30.0, 0.1) var text_speed: float = 18.0
@export var text_sound: AudioStream
@export var text_volume_db: int = -8
@export var text_volume_pitch_min: float = 0.85
@export var text_volume_pitch_max: float = 1.15