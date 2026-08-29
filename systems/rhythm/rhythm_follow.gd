extends Control

# camera
@onready var cam: Camera2D = $cam

# different paths
@onready var simple: Path2D = $simple
@onready var mid: Path2D = $mid

# path attributes
var curr_path: Path2D
var hit_follow: PathFollow2D
var hit_area: Area2D
var path_line: Line2D


# pulse attributes
@export var pulse_speed: float = 300.0
@export var hit_speed: float = 13.0
@export var number_of_pulses: int = 8

# exporting pulse scene, script
var pulse_scene: PackedScene = preload("res://systems/rhythm/pulse.tscn")
var pulse_follow_script: Script = preload("res://systems/rhythm/pulse_follow.gd")

# heartbeat attributes
var heartbeat: Array[float] = []
var elapsed: float = 0.0
var next_pulse: int = 0


func _ready() -> void:
	Global.register_cam(cam)
	set_condition("simple")
	create_heartbeat()


func _process(delta: float) -> void:
	# tracking the heartbeat
	elapsed += delta
	if next_pulse < heartbeat.size():
		if elapsed >= heartbeat[next_pulse]:
			spawn_pulse()
			next_pulse += 1
	# move the hit bar
	if is_instance_valid(hit_follow):
		hit_follow.progress += hit_speed * delta


# input func
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		check_hit()


# set the rhtyhm difficulty
func set_condition(condition: String) -> void:
	hit_follow = null
	hit_area = null
	# switch case difficulty  
	match condition:
		"simple":
			curr_path = simple
		"mid":
			curr_path = mid
		_:
			push_error("Unknown rhythm condition: " + condition)
			return
	# get pathFollow, area2d children using alias
	hit_follow = curr_path.get_node("hitFollow") as PathFollow2D
	hit_area = hit_follow.get_node("hitZone/Area2D") as Area2D
	path_line = curr_path.get_node("line") as Line2D
	draw_path(curr_path, path_line)
	
	hit_follow.progress = 0.0
	hit_follow.loop = true
	hit_follow.rotates = false


# draw the path line
func draw_path(path: Path2D, line: Line2D):
	line.clear_points()
	var points: PackedVector2Array = path.curve.get_baked_points()
	line.points = points

# spawn in (instantiate) pulses
func spawn_pulse() -> void:
	if curr_path == null:
		return
	if curr_path.curve == null:
		return
	# make the pulses follow path 
	var follow: PathFollow2D = PathFollow2D.new()
	follow.set_script(pulse_follow_script)
	follow.loop = false
	follow.rotates = true
	curr_path.add_child(follow)
	var pulse: Node2D = pulse_scene.instantiate() as Node2D
	if pulse == null:
		push_error(	"Pulse root must inherit from Node2D.")
		follow.queue_free()
		return
	follow.add_child(pulse)
	follow.progress = curr_path.curve.get_baked_length()
	follow.speed = pulse_speed


# random generation of spawn time of pulses 
func create_heartbeat() -> void:
	heartbeat.clear()
	var current_time: float = 0.0
	for i: int in range(number_of_pulses):
		var interval: float = randf_range(0.5,1.6)
		current_time += interval
		heartbeat.append(current_time)


# check if the player is successful
func check_hit() -> void:
	if hit_area == null:
		return
	var areas: Array[Area2D] = (hit_area.get_overlapping_areas())
	for area: Area2D in areas:
		if area.is_in_group("pulse"):
			print("GOOD!")
			Global.shake(0.3)
			var pulse: Node = area.get_parent()
			var pulse_follow: Node = pulse.get_parent()
			pulse_follow.queue_free()
			return
	print("MISS!")
