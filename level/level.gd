extends Node3D

signal minigame_finished(confidence_change: float, anxiety_change: float)
signal minigame_started(game: String)

@onready var player: CharacterBody3D = $player
@onready var dialogue: CanvasLayer = $UI/dialogue
@onready var meters: Control = $UI/meters
@onready var pattern_recog = preload("res://systems/pattern/pattern_recog.tscn")

var confidence := 70.0
var anxiety := 40.0


func _ready() -> void:
	minigame_started.connect(player._on_minigame_started)

	await get_tree().create_timer(3.0).timeout

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var pattern = pattern_recog.instantiate()
	add_child(pattern)

	minigame_started.emit("pattern")

	pattern.minigame_finished.connect(_on_minigame_finished)

	meters.update_meters(confidence, anxiety)


func _on_player_dialogue_requested(dialogues: Array) -> void:
	for d in dialogues:
		dialogue.show_msg(d)
		await dialogue.message_finished

	player.finish_intro()


func _on_minigame_finished(confidence_change: float, anxiety_change: float) -> void:
	confidence = clamp(confidence + confidence_change, 0.0, 100.0)
	anxiety = clamp(anxiety + anxiety_change, 0.0, 100.0)

	meters.update_meters(confidence, anxiety)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
