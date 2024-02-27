class_name placeable

extends CharacterBody3D

@onready var temp_marker:PackedScene = preload("res://scenes/temp_marker.tscn")
@onready var collider = $CollisionShape3D
@onready var snap_points = $snap_points
@onready var marker2 = $marker2
@export var support_points_needed = 2
var nametag = null
var id = null

var selected_snap:Node3D
var selected_snap_index:int

func _ready():
	id = randi() % 100 + 1
	nametag = find_child("nametag")
	if(nametag):
		nametag.text = str(id)

func init(snap_index:int):
	selected_snap_index = snap_index
	var points = snap_points.get_children()
	if(snap_index>points.size()-1):
		selected_snap = points[0]
	else:
		selected_snap = points[snap_index]
	marker2.position = selected_snap.position
	
func check_for_support()->bool:
	if(selected_snap and selected_snap.name.contains("origin")):
		return true
	var supported = false
	var points = snap_points.get_children()
	var num_supported_points = 0
	for p in points:
		var bodies = p.get_overlapping_bodies()
		if(bodies.size()>0):
			place_marker(p.global_position)
			num_supported_points +=1
	if(num_supported_points>=support_points_needed):
		supported = true
	return supported
	
func get_neighbors()->Array:
	var neighbors:Array = []
	for p in snap_points.get_children():
		var bodies = p.get_overlapping_bodies()
		for b in bodies:
			if(b is placeable and b != self and !neighbors.has(b.id) ):
				neighbors.push_back(b.id)
			elif(!(b is placeable) and b.is_in_group("ground") and !neighbors.has("ground") ):
				neighbors.push_back("ground")
	
	if(nametag):
		var text = "\nNeighbors:\n"
		for n in neighbors:
			text += str(n) + ","
		nametag.text = str(id) + text
	return neighbors
	

func on_place():
	collider.disabled = false
	marker2.visible = false
	set_physics_process(false)
	
func on_remove():
	queue_free()
	
#returns the node of the nearest snap point to the given vector 3
func get_nearest_snap_point(pos:Vector3)->Node3D:
	var points = snap_points.get_children()
	var lowest_distance = 999
	var closest_snap_point:Node3D = null
	for point in points:
		var dist = point.global_position.distance_to(pos)
		if(dist<lowest_distance):
			lowest_distance = dist
			closest_snap_point = point
	return closest_snap_point
	
	
func cycle_snap(dir:String)->int:
	var points = snap_points.get_children()
	if(dir=="left"):
		selected_snap_index += 1
	else:
		selected_snap_index -= 1
	if(selected_snap_index>points.size()-1):
		selected_snap_index = 0
	if(selected_snap_index<0):
		selected_snap_index = points.size()-1
	selected_snap = points[selected_snap_index]
	marker2.position = selected_snap.position
	return selected_snap_index
	
func get_snap_at_index(index:int)->Node3D:
	var points = snap_points.get_children()
	if(index>points.size()-1):
		return points[0]
	else:
		return points[index]
	
	
func put_snap_at_pos(pos:Vector3):
	var new_pos = pos-(selected_snap.global_position-global_position)
	global_position = new_pos
	
func place_marker(pos:Vector3):
	var m:GPUParticles3D = temp_marker.instantiate()
	get_tree().get_current_scene().add_child(m)
	m.global_position = pos
