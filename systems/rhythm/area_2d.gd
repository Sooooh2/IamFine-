extends Area2D

var pulses_inside: Array[Area2D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("pulse"):
		if not pulses_inside.has(area):
			pulses_inside.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area in pulses_inside:
		pulses_inside.erase(area)


func has_pulse() -> bool:
	return not pulses_inside.is_empty()


func get_pulse() -> Area2D:
	if pulses_inside.is_empty():
		return null

	return pulses_inside[0]
