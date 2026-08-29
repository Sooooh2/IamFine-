extends Node


var trauma := 0.0
var max_offset := 2.0
var decay := -2.0

var cam : Camera2D


func register_cam(camera : Camera2D) -> void:
	cam = camera


func shake(amt : float) -> void:
	trauma = clamp(trauma + amt , 0.0 , 1.0)


func _process(delta: float) -> void:
	if cam == null:
		return
	
	if trauma > 0.0:
		trauma = max(trauma * decay * delta,0.0)
		var strength = trauma * trauma 
		cam.offset = Vector2(randf_range(-max_offset,max_offset),randf_range(-max_offset,max_offset)) * 2
	else: 
		cam.offset = Vector2.ZERO
