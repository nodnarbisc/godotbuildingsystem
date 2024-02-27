extends Camera3D

@export var speed:float = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(get_parent().global_transform, speed*delta)
