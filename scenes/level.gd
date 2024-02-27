extends Node3D

@onready var wall = $wall/CollisionShape3D
@onready var floor = $floor/CollisionShape3D
@onready var floor2 = $floor2/CollisionShape3D


func _ready():
	wall.disabled = false
	floor.disabled = false
	floor2.disabled = false
	var wall_parent =  wall.get_parent()
	wall_parent = null
