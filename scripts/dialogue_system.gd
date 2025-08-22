extends Control

const DialogueButtonPreload: PackedScene = preload("res://scenes/dialogue_button.tscn")
@onready var DialogueLabel: RichTextLabel = $HBoxContainer/VBoxContainer/RichTextLabel

var dialogue: Array[DE]
var current_dialogue_item: int   = 0
var next_item: bool              = true
var player_node: CharacterBody2D
var is_processing_dialogue: bool = false


func _ready() -> void:
	visible = false
	$HBoxContainer/VBoxContainer/button_container.visible = false
	_find_player()


func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group('player')
	if players.size() > 0:
		player_node = players[0]
	else:
		call_deferred("_find_player")


func _process(_delta: float) -> void:
	if current_dialogue_item >= dialogue.size():
		_end_dialogue()
		return

	if next_item and not is_processing_dialogue:
		_process_next_dialogue_item()


func _process_next_dialogue_item() -> void:
	next_item = false
	is_processing_dialogue = true

	var item: DE = dialogue[current_dialogue_item]

	if item is DialogueFunction:
		visible = not item.hide_dialogue_box
		await _function_resource(item)
	elif item is DialogueChoice:
		visible = true
		await _choice_resource(item)
	elif item is DialogueText:
		visible = true
		await _text_resource(item)
	else:
		push_error("Unknown dialogue type: " + str(item))
		_advance_dialogue()

	is_processing_dialogue = false


func _end_dialogue() -> void:
	if player_node:
		player_node.can_move = true
	queue_free()


func _advance_dialogue() -> void:
	current_dialogue_item += 1
	next_item = true


func _animate_text(text: String, speed: float, audio_stream: AudioStream = null, volume_db: int = -8, pitch_min: float = 0.85, pitch_max: float = 1.15) -> void:
	DialogueLabel.visible_characters = 0
	DialogueLabel.text = text

	_setup_audio(audio_stream, volume_db)

	var clean_text: String    = _text_without_square_brackets(text)
	var total_characters: int = clean_text.length()

	if total_characters == 0:
		return

	await get_tree().process_frame

	var character_timer: float = 0.0

	while DialogueLabel.visible_characters < total_characters:
		# Skip animation avec E
		if Input.is_action_just_pressed('Interact'):
			DialogueLabel.visible_characters = total_characters
			break

		character_timer += get_process_delta_time()
		var time_per_character: float = 1.0 / speed
		var current_char: String      = clean_text[DialogueLabel.visible_characters]

		if character_timer >= time_per_character or current_char == " ":
			DialogueLabel.visible_characters += 1

			if current_char != " " and audio_stream:
				_play_character_sound(pitch_min, pitch_max)

			character_timer = 0.0

		await get_tree().process_frame


func _setup_audio(audio_stream: AudioStream, volume_db: int) -> void:
	if audio_stream:
		$AudioStreamPlayer.stream = audio_stream
		$AudioStreamPlayer.volume_db = volume_db


func _play_character_sound(pitch_min: float, pitch_max: float) -> void:
	$AudioStreamPlayer.pitch_scale = randf_range(pitch_min, pitch_max)
	$AudioStreamPlayer.play()


func _handle_camera_movement(camera_position: Vector2, transition_time: float) -> Tween:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if not camera or camera_position == Vector2(999.999, 999.999):
		return null

	var target_position: Vector2 = _resolve_camera_position(camera_position)

	if target_position == Vector2(999.999, 999.999):
		return null

	var camera_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	camera_tween.tween_property(camera, "global_position", target_position, transition_time)
	return camera_tween


func _resolve_camera_position(camera_position: Vector2) -> Vector2:
	if camera_position == Vector2(-1, -1):
		if not player_node:
			_find_player()
		return player_node.global_position if player_node else Vector2(999.999, 999.999)

	return camera_position


func _function_resource(item: DialogueFunction) -> void:
	var target_node: Node = get_node_or_null(item.target_path)
	if not _validate_function_call(target_node, item):
		_advance_dialogue()
		return

	if item.function_arguments.size() == 0:
		target_node.call(item.function_name)
	else:
		target_node.callv(item.function_name, item.function_arguments)

	if item.wait_for_signal_to_continue:
		await _wait_for_signal(target_node, item.wait_for_signal_to_continue)

	_advance_dialogue()


func _validate_function_call(target_node: Node, item: DialogueFunction) -> bool:
	if not target_node:
		push_error("DialogueFunction: Target node not found: " + str(item.target_path))
		return false

	if not target_node.has_method(item.function_name):
		push_error("DialogueFunction: Method '" + item.function_name + "' not found on " + str(target_node))
		return false

	return true


func _wait_for_signal(target_node: Node, signal_name: String) -> void:
	if not target_node.has_signal(signal_name):
		push_warning("Signal '" + signal_name + "' not found on " + str(target_node))
		return

	var signal_state: Dictionary = { "received": false }
	var callable                 = func(_args): signal_state.received = true

	target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)

	while not signal_state.received:
		await get_tree().process_frame


func _choice_resource(item: DialogueChoice) -> void:
	await _animate_text(item.text, item.text_speed, item.text_sound,
	item.text_volume_db, item.text_volume_pitch_min, item.text_volume_pitch_max)

	_create_choice_buttons(item)


func _create_choice_buttons(item: DialogueChoice) -> void:
	$HBoxContainer/VBoxContainer/button_container.visible = true

	for i in item.choice_text.size():
		var button: Node = DialogueButtonPreload.instantiate()
		button.text = item.choice_text[i]

		_connect_button_signals(button, item.choice_function_call[i])

		$HBoxContainer/VBoxContainer/button_container.add_child(button)

	var first_button: Node = $HBoxContainer/VBoxContainer/button_container.get_child(0)
	if first_button:
		first_button.grab_focus()


func _connect_button_signals(button: Node, function_resource: DialogueFunction) -> void:
	if function_resource:
		var target_node: Node = get_node_or_null(function_resource.target_path)
		if target_node and target_node.has_method(function_resource.function_name):
			button.connect("pressed",
			Callable(target_node, function_resource.function_name).bindv(function_resource.function_arguments),
			CONNECT_ONE_SHOT)

		if function_resource.hide_dialogue_box:
			button.connect("pressed", hide, CONNECT_ONE_SHOT)

		button.connect("pressed",
		_choice_button_pressed.bind(target_node, function_resource.wait_for_signal_to_continue),
		CONNECT_ONE_SHOT)
	else:
		button.connect("pressed", _choice_button_pressed.bind(null, ""), CONNECT_ONE_SHOT)


func _text_resource(item: DialogueText) -> void:
	var camera_tween: Tween = _handle_camera_movement(item.camera_position, item.camera_transition_time)

	await _animate_text(item.text, item.text_speed, item.text_sound,
	item.text_volume_db, item.text_volume_pitch_min, item.text_volume_pitch_max)

	await _wait_for_continue_input(camera_tween, item.text)


func _wait_for_continue_input(camera_tween: Tween, text: String) -> void:
	var text_length: int = _text_without_square_brackets(text).length()

	while true:
		await get_tree().process_frame

		if DialogueLabel.visible_characters >= text_length:
			if Input.is_action_just_pressed('Interact'):
				if camera_tween and camera_tween.is_valid():
					await camera_tween.finished

				_advance_dialogue()
				break


func _choice_button_pressed(target_node: Node, wait_for_signal_to_continue: String) -> void:
	_clear_choice_buttons()

	if wait_for_signal_to_continue and target_node:
		await _wait_for_signal(target_node, wait_for_signal_to_continue)

	_advance_dialogue()


func _clear_choice_buttons() -> void:
	$HBoxContainer/VBoxContainer/button_container.visible = false
	for child in $HBoxContainer/VBoxContainer/button_container.get_children():
		child.queue_free()


func _text_without_square_brackets(text: String) -> String:
	var result: String    = ""
	var in_brackets: bool = false

	for character in text:
		if character == "[":
			in_brackets = true
		elif character == "]":
			in_brackets = false
		elif not in_brackets:
			result += character

	return result


func _exit_tree() -> void:
	if player_node:
		player_node = null
