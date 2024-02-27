extends Node

@export var ray:RayCast3D
@export var default_buid_piece:PackedScene = preload("res://scenes/floor.tscn")
@onready var placement_mat = preload("res://materials/placing_material.tres")
@onready var build_menu = $build_menu
var snap_range = 0.5

var in_build_mode = false

#These are the 4 things needed to define where a placable item should go:
var fixed_item:Node3D	#The already placed item that we want to snap to
var free_item:Node3D   #the thing we're actively placing
var fixed_point:Node3D	#the point on the fixed item we're snapping to
var free_point:Node3D	#the free item's selected snap point


var initialized = false
var last_used_snap_index = 0
var last_used_rotation = Basis()
var auto_snap = false
var supported = false
var selected:
	set(new):
		selected = new
		switch_placeable(selected)
		print(selected.resource_path)

func _ready():
	build_menu.visible = false
	#initialized = true;
	
func switch_placeable(s):
	if(free_item):
		free_item.queue_free()
	free_item = s.instantiate()
	get_tree().get_current_scene().add_child(free_item)
	free_item.global_transform.basis = last_used_rotation
	free_item.init(last_used_snap_index)
		
func _process(_delta):
	if(Input.is_action_just_pressed("B")):
		toggle_build_mode()
#	if(!in_build_mode):
#		return
	if(Input.is_action_just_pressed("left_click")):
		if(!build_menu.visible):
			place()
	if(Input.is_action_just_pressed("right_click")):
		if(!build_menu.visible):
			remove()
	if(Input.is_action_just_pressed("scroll_down")):
		if(free_item):
			free_item.rotate_y(deg_to_rad(15))
			last_used_rotation = free_item.global_transform.basis
	if(Input.is_action_just_pressed("scroll_up")):
		if(free_item):
			free_item.rotate_y(deg_to_rad(-15))
			last_used_rotation = free_item.global_transform.basis
	if(Input.is_action_just_pressed("F")):
		if(free_item):
			free_item.rotate_x(deg_to_rad(180))
			last_used_rotation = free_item.global_transform.basis
	if(Input.is_action_just_pressed("E") and free_item):
		last_used_snap_index = free_item.cycle_snap("right")
	if(Input.is_action_just_pressed("Q")):
		last_used_snap_index = free_item.cycle_snap("left")
	if(Input.is_action_just_pressed("tab")):
		build_menu.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if(Input.is_action_just_released("tab")):
		build_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if(Input.is_action_just_pressed("R")):
		if(ray.is_colliding()):
			var col = ray.get_collider()
			if col is placeable:
				print(col.get_neighbors())
				print("\n")
		
func toggle_build_mode():
	in_build_mode = !in_build_mode
	if(!selected):
		selected = default_buid_piece
	switch_placeable(selected)
	if(free_item):
		free_item.queue_free()
		free_item = null
		
func _physics_process(_delta):
#	if(!initialized):
#		return
	if(!in_build_mode):
		return
	if(!ray.is_colliding()): #return and remove the free item if ray isn't colliding with anything
		if free_item: 
			free_item.visible = false
		return
	fixed_item = ray.get_collider()
	if(!free_item): #if there isn't a free item already, create one
		switch_placeable(selected)
	free_item.visible = true
	if(fixed_item is placeable): #If the ray is hiting a build item
		fixed_point = fixed_item.get_nearest_snap_point(ray.get_collision_point())
		free_item.selected_snap = free_item.get_snap_at_index(last_used_snap_index)
		free_point = free_item.selected_snap
		if(free_point.global_position.distance_to(fixed_point.global_position)<snap_range):
			free_item.put_snap_at_pos(fixed_point.global_position)
		else:
			free_item.put_snap_at_pos(ray.get_collision_point())	
	else:
		free_item.put_snap_at_pos(ray.get_collision_point())

func place():
	if(!free_item):
		return
	if(!free_item.check_for_support()):
		print("Not supported")
		return
	free_item.on_place()
	free_item = null
	
func remove():
	if(ray.is_colliding() and ray.get_collider() is placeable):
		ray.get_collider().on_remove()
