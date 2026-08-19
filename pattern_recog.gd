extends Control

@onready var grid: HBoxContainer = $grid

var grid_size := 5
var seq_len := 5
func _ready() -> void:
	randomize()
	play_sequence()

func get_cell(x: int, y: int) -> ColorRect:
	return grid.get_child(x).get_child(y)


func play_sequence() -> void: 
	for i in range(seq_len):
		var x = randi_range(0,grid_size-1)
		var y = randi_range(0,grid_size-1)
		
		var cell = get_cell(x,y)
		cell.modulate = Color.REBECCA_PURPLE
		await get_tree().create_timer(0.5).timeout
		
		cell.modulate = Color.WHITE
		await get_tree().create_timer(0.2).timeout
