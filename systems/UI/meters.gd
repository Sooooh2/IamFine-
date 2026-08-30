extends Control

@onready var confidence: ProgressBar = $HBoxContainer/confidenceBar
@onready var anxiety: ProgressBar = $HBoxContainer/anxietyBar


signal minigame_finished(confidence_change: float, anxiety_change: float)


func update_meters(confidence_value: float, anxiety_value: float) -> void:
	confidence.value = confidence_value
	anxiety.value = anxiety_value
