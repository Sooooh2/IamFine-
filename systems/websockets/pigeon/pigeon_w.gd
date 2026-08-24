extends Node2D

@export var speed := 250.0
@export var arrive_distance := 10.0

var target: Node2D
var message := ""


func setup(target_node: Node2D, new_message: String):
	target = target_node
	message = new_message


func _process(delta):
	if not target:
		return

	global_position = global_position.move_toward(
		target.global_position,
		speed * delta
	)

	if global_position.distance_to(target.global_position) <= arrive_distance:
		deliver()


func deliver():
	if target.has_method("receive_update"):
		target.receive_update(message)

	queue_free()
