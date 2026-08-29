extends Node3D

@onready var player: CharacterBody3D = $player
@onready var pattern_recog = preload("res://systems/pattern/pattern_recog.tscn")
@onready var dialogue: CanvasLayer = $dialogue

var is_intro := true

func _ready() -> void:
	player.dialogue_requested.connect(_on_player_dialogue_requested)
	intro()


func intro() -> void:
	if !is_intro:
		return

	print("start of the game")
	
	

func _on_player_dialogue_requested(dialogues: Array) -> void:
	for d in dialogues:
		print("asdfghjk")
		dialogue.show_msg(d)
		await get_tree().create_timer(2.5).timeout
