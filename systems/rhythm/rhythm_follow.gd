extends Control

@onready var pulses: Control = $pulse
@onready var hit_zone: ColorRect = $hitZone
@onready var cam: Camera2D = $cam
@export var shake_strength := 0.0
@export var shake_fade := 5.0

var pulse_scene = preload("res://systems/rhythm/pulse.tscn")
var pulse_speed := 300.0

var heartbeat = []
var number_of_pulses := 5

var elapsed := 0.0
var next_pulse := 0
var hit_speed := 13.0

var og_pos := Vector2.ZERO
var random_offset : Vector2


func _ready():
	og_pos = cam.global_position
	elapsed = 0.0
	next_pulse = 0
	create_heartbeat()


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			check_hit()


func _process(delta):
	elapsed += delta
	if next_pulse < heartbeat.size():
		if elapsed >= heartbeat[next_pulse]:
			spawn_pulse()
			next_pulse += 1
	hit_zone.position.x += hit_speed * delta
	
	if shake_strength > 0:
		cam.position = og_pos + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerpf(shake_strength,0.0,shake_fade * delta)
	else:
		cam.position = og_pos


func spawn_pulse():
	var pulse = pulse_scene.instantiate()
	pulses.add_child(pulse)
	pulse.position = Vector2(400,$hitZone.position.y)
	pulse.speed = pulse_speed


func create_heartbeat():
	heartbeat.clear()
	var current_time := 0.0
	
	for i in range(number_of_pulses):
		var interval = randf_range(0.5, 1.6)
		current_time += interval
		heartbeat.append(current_time)


func check_hit():
	var closest_pulse = null
	var closest_distance = INF
	
	for pulse in pulses.get_children():
		var distance = abs(pulse.global_position.x -$hitZone.global_position.x)
		if distance < closest_distance:
			closest_distance = distance
			closest_pulse = pulse
	if closest_pulse == null:
		return
	if closest_distance < 40:
		print("GOOD!")
		apply_shake()
		closest_pulse.queue_free()
	else:
		print("MISS!")


func apply_shake():
	print("Should shake")
	shake_strength = 10.0
