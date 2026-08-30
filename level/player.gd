extends CharacterBody3D

signal dialogue_requested(dialogue: Array[String])

@onready var cam_rig: Node3D = $camrig
@onready var start_cam: Camera3D = $camrig2/cam
@onready var main_cam: Camera3D = $camrig/cam
@onready var sprite_3d: Sprite3D = $Sprite3D

@export var mouse_sens := 0.001

var pitch := 0.0
var intro := true

var first_talk: Array[String] = [
	"Okay, we are here now.........",
	"I am going to be just fine.",
	"Just breathe in......... breathe out..........",
	"Everything is going to be just fine."
]


func _ready() -> void:
	start_cam.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	intro_thing()


func _input(event: InputEvent) -> void:
	if intro:
		return

	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		cam_rig.rotation.y -= event.relative.x * mouse_sens
		cam_rig.rotation.y = clamp(
			cam_rig.rotation.y,
			deg_to_rad(-50),
			deg_to_rad(50)
		)

		pitch -= event.relative.y * mouse_sens
		pitch = clamp(
			pitch,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

		cam_rig.rotation.x = pitch


func intro_thing() -> void:
	sprite_3d.visible = true
	await get_tree().create_timer(1.0).timeout
	dialogue_requested.emit(first_talk)


func finish_intro() -> void:
	intro = false



func _on_minigame_started(type: String) -> void:
	if type == "pattern":
		shift_camera_left()


func shift_camera_left() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		start_cam,
		"position:x",
		start_cam.position.x - 0.5,
		0.5
	)
