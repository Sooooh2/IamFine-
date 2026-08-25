extends Node2D

signal player_entered


func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		print("sdasdfgfewqwertyhreweg")
		player_entered.emit()
