extends CharacterBody2D

@export var speed := 600.0

var can_move := true
var nearby_interactable: Node = null

func _ready():
	add_to_group("player")
	print("PLAYER READY")


func _physics_process(delta):

	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("left","right","up","down")

	velocity = direction * speed

	move_and_slide()


func _unhandled_input(event):

	if event.is_action_pressed("interact"):

		if nearby_interactable:
			nearby_interactable.interact()
