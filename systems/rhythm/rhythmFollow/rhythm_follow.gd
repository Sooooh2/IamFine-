extends Control


signal minigame_finished(confidence_change: float, anxiety_change: float)


# camera
@onready var cam: Camera2D = $cam

# different paths
@onready var simple: Path2D = $simple
@onready var mid: Path2D = $mid
@onready var hard: Path2D = $hard
@onready var harder: Path2D = $harder

# different values for diffuclties
var difficulties = {
	"simple":{
		"pulse_speed": 300.0,
		"hit_speed":13.0,
		"number_of_pulses":6
	},
	"mid":{
		"pulse_speed": 500.0,
		"hit_speed":18.0,
		"number_of_pulses":8
	},
	"hard":{
		"pulse_speed": 500.0,
		"hit_speed":40.0,
		"number_of_pulses":10
	},
	"harder":{
		"pulse_speed": 500.0,
		"hit_speed":40.0,
		"number_of_pulses":10
	}
}

# path attributes
var curr_path: Path2D
var hit_follow: PathFollow2D
var hit_area: Area2D


# pulse attributes
var pulse_speed: float
var hit_speed: float
var number_of_pulses: int

# exporting pulse scene, script
var pulse_scene: PackedScene = preload("res://systems/rhythm/pulse/pulse.tscn")
var pulse_follow_script: Script = preload("res://systems/rhythm/pulse_follow.gd")

# heartbeat attributes
var heartbeat: Array[float] = []
var elapsed: float = 0.0
var next_pulse: int = 0


# register cam in global, set initial difficulties 
func _ready() -> void:
	Global.register_cam(cam)
	set_condition("mid")


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
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		check_hit()


# set the rhtyhm difficulty
func set_condition(condition: String) -> void:
	if not difficulties.has(condition):
		push_error("Unknown rhythm condition: " + condition)
		return
	match condition:
		"simple":
			curr_path = simple
		"mid":
			curr_path = mid
		"hard":
			curr_path = hard
		"harder":
			curr_path = harder
	var settings: Dictionary = difficulties[condition]
	
	pulse_speed = settings["pulse_speed"]
	hit_speed = settings["hit_speed"]
	number_of_pulses = settings["number_of_pulses"]
	
	hit_follow = curr_path.get_node("hitFollow") as PathFollow2D
	hit_area = hit_follow.get_node("hitZone/Area2D") as Area2D
	
	hit_follow.progress = 0.0
	hit_follow.loop = true
	hit_follow.rotates = true
	
	elapsed = 0.0
	next_pulse = 0
	
	create_heartbeat()


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
		push_error("Pulse root must inherit from Node2D.")
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
		var interval: float = randf_range(0.5, 1.6)
		current_time += interval
		heartbeat.append(current_time)


# check if the player is successful
func check_hit() -> void:
	if hit_area == null:
		return
	
	var areas: Array[Area2D] = hit_area.get_overlapping_areas()
	
	for area: Area2D in areas:
		if area.is_in_group("pulse"):
			minigame_finished.emit(10.0, -8.0)
			print("GOOD!")
			Global.shake(0.3)
			
			var pulse: Node2D = area.get_parent()
			var pulse_follow: Node2D = pulse.get_parent()
			var material := pulse.material as ShaderMaterial

			var tween := create_tween()
			tween.set_parallel(true)

			tween.tween_property(
				pulse,
				"scale",
				pulse.scale * 2.0,
				0.15
			)

			tween.tween_method(
				func(value: Color) -> void:
					material.set_shader_parameter("pulse_color", value),
				Color(0.3, 0.7, 1.0, 1.0),
				Color.WHITE,
				0.15
			)

			tween.tween_method(
				func(value: float) -> void:
					material.set_shader_parameter("glow_strength", value),
				2.0,
				10.0,
				0.15
			)

			tween.tween_property(
				pulse,
				"modulate:a",
				0.0,
				0.15
			)

			tween.set_parallel(false)
			tween.tween_callback(pulse_follow.queue_free)
			
			return
	
	print("MISS!")
	minigame_finished.emit(-10.0, 10.0)
