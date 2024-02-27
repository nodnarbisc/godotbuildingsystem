extends Button

@onready var building_manager = %building_manager
@export var build_piece:PackedScene



func _on_pressed():
	building_manager.selected = build_piece
