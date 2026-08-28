extends CharacterBody3D

@onready var cam_rig: Node3D = $camrig
@onready var startCam: Camera3D = $camrig2/cam
@onready var mainCam: Camera3D = $camrig/cam
@onready var sprite_3d: Sprite3D = $Sprite3D

@export var mouse_sens := 0.001

var pitch := 0.0
var intro := true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	introthing()


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


func introthing() -> void:
	sprite_3d.visible = true
	startCam.make_current()

	await get_tree().create_timer(1.0).timeout

	intro = false
	sprite_3d.visible = false
	mainCam.make_current()
