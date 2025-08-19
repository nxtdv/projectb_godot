extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var dialogue_ui: Control = $DialogueUI
@onready var dialogue_label: Label = $DialogueUI/DialoguePanel/VBoxContainer/DialogueLabel
@onready var continue_label: Label = $DialogueUI/DialoguePanel/VBoxContainer/ContinueLabel
enum State {
	IDLE,
	ENTERING_INTERACTION,
	INTERACTING,
	EXITING_INTERACTION
}
var current_state: State  = State.IDLE
var player_in_range: bool = false
# Système de dialogue
var dialogue_lines: Array[String] = ["Bonjour ! Bienvenue dans ma boutique !", "J'ai les meilleures potions de la région.", "Que puis-je faire pour vous aider ?", "N'hésitez pas à revenir quand vous voulez !"]
var current_dialogue_index: int   = 0


func _ready() -> void:
	# Connecter les signaux
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	# Cacher l'UI de dialogue au début
	dialogue_ui.visible = false

	# Commencer en idle
	animated_sprite.play("idle")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		if player_in_range and current_state == State.IDLE:
			_start_interaction()
		elif current_state == State.INTERACTING:
			_advance_dialogue()


func _start_interaction() -> void:
	if current_state == State.IDLE:
		current_state = State.ENTERING_INTERACTION
		animated_sprite.play("interacting_entry")
		current_dialogue_index = 0  # Reset du dialogue


func _advance_dialogue() -> void:
	if current_dialogue_index < dialogue_lines.size():
		dialogue_label.text = dialogue_lines[current_dialogue_index]
		current_dialogue_index += 1

		# Afficher le texte pour continuer ou fermer
		if current_dialogue_index < dialogue_lines.size():
			continue_label.text = "[E] Continuer"
		else:
			continue_label.text = "[E] Fermer"
	else:
		# Fin du dialogue
		_end_interaction()


func _end_interaction() -> void:
	if current_state == State.INTERACTING:
		current_state = State.EXITING_INTERACTION
		animated_sprite.play("interacting_rest")
		dialogue_ui.visible = false


func _on_animation_finished() -> void:
	match animated_sprite.animation:
		"interacting_entry":
			# Entrée terminée → commencer la boucle d'interaction
			current_state = State.INTERACTING
			animated_sprite.play("interacting_loop")
			# Afficher l'UI et commencer le dialogue
			dialogue_ui.visible = true
			_advance_dialogue()

		"interacting_rest":
			# Sortie terminée → retour à l'idle
			current_state = State.IDLE
			animated_sprite.play("idle")


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("[E] Parler au marchand")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		# Forcer la fin de l'interaction si le joueur s'éloigne
		if current_state == State.INTERACTING:
			_end_interaction()


# Fonction pour terminer l'interaction (à appeler depuis un menu/dialogue)
func close_interaction() -> void:
	_end_interaction()
