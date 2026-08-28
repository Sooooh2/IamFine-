extends Node3D

@onready var player: CharacterBody3D = $player
@onready var pattern_recog = preload("res://systems/pattern/pattern_recog.tscn")


func _ready() -> void:
	print("BEFORE:", Time.get_ticks_msec())
	
	await get_tree().create_timer(6.0).timeout
	
	print("AFTER:", Time.get_ticks_msec())
	confidence_boost()


func confidence_boost():
	print("pattern game here")
	var patt = pattern_recog.instantiate()
	add_child(patt)
