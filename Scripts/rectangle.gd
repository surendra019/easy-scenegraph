extends Control


class_name Rectangle

@onready var corners: Node2D = $Corners

const CORNER = preload("res://Scenes/Prefabs/corner.tscn")

const dragger_width: float = 20
var id: String
@export var component_type_idx: int

var holded: bool

var drag_start_pos: Vector2
var drag_start_size: Vector2
var handle_dragged: int

func _ready() -> void:
	initialize()
	connect_input()
	if "dot" in self:
		move_child(self["dot"], -1)


func connect_input() -> void:
	# Connect the inputs signal for each handle
	for handle in corners.get_children():
		if handle is ColorRect:
			handle.gui_input.connect(_on_handle_input.bind(corners.get_children().find(handle)))
	



func _resize_rectangle(delta: Vector2, handle_id: int):
	var mouse_pos = get_global_mouse_position()
	var rect_end = position + size
	print("cale")
	match handle_id:
		0:
			position.y += mouse_pos.y - position.y
			size.y =  drag_start_size.y - (mouse_pos.y - drag_start_pos.y)
			var can_drag: bool 
			if component_type_idx == 1:
				if size.x < self["max_width"]:
					if drag_start_size.x - (mouse_pos.x - drag_start_pos.x) - size.x > 0:
						can_drag = true
				if size.x > self["min_width"]:
					if drag_start_size.x - (mouse_pos.x - drag_start_pos.x) - size.x < 0:
						can_drag = true
			else:
				can_drag = true
			if can_drag:
				position.x += mouse_pos.x - position.x
				size.x =  drag_start_size.x - (mouse_pos.x - drag_start_pos.x)
		1:
			size.y = drag_start_size.y - (mouse_pos.y - drag_start_pos.y)
			position.y = clamp(position.y + mouse_pos.y - position.y, -INF, drag_start_pos.y + drag_start_size.y)
			var can_drag: bool
			if component_type_idx == 1:
				if size.x < self["max_width"]:
					if drag_start_size.x + (mouse_pos.x - drag_start_pos.x) - size.x > 0:
						can_drag = true
				if size.x > self["min_width"]:
					if drag_start_size.x + (mouse_pos.x - drag_start_pos.x) - size.x < 0:
						can_drag = true
			else:
				can_drag = true
			if can_drag:
				size.x = drag_start_size.x + (mouse_pos.x - drag_start_pos.x)
		3:
			size.y = mouse_pos.y - position.y
			#position.y = clamp(position.y + mouse_pos.y - position.y, -INF, drag_start_pos.y + drag_start_size.y)
			var can_drag: bool = false
			if component_type_idx == 1:
				if size.x < self["max_width"]:
					if drag_start_size.x - (mouse_pos.x - drag_start_pos.x) - size.x > 0:
						can_drag = true
				if size.x > self["min_width"]:
					if drag_start_size.x - (mouse_pos.x - drag_start_pos.x) - size.x < 0:
						can_drag = true
			else:
				can_drag = true
			if can_drag:
				position.x = clamp(position.x + mouse_pos.x - position.x, -INF, drag_start_pos.x + drag_start_size.x)
				size.x = drag_start_size.x - (mouse_pos.x - drag_start_pos.x)
		2:
			size.y = mouse_pos.y - position.y
			var can_drag: bool
			if component_type_idx == 1:
				if size.x < self["max_width"]:
					if mouse_pos.x - position.x - size.x > 0:
						can_drag = true
				if size.x > self["min_width"]:
					if mouse_pos.x - position.x - size.x < 0:
						can_drag = true
			else:
				can_drag = true
			if can_drag:
				size.x = mouse_pos.x - position.x
				
				
			
			

func _process(delta: float) -> void:
	if get_tree().has_group("main"):
		if get_tree().get_first_node_in_group("main").current_rectangle == self && get_mode() == 1:
			_show_corners()
		else:
			_hide_corners()
	if get_mode() == 0:
		self_modulate.a = 0
	else:
		self_modulate.a = 1
		
	_set_corner_positions()

# returns the current mode.
func get_mode() -> int:
	return get_tree().get_first_node_in_group("scene").current_mode
	
func _set_corner_positions() -> void:
	corners.get_child(0).position = -corners.get_child(0).size / 2
	corners.get_child(1).position = Vector2(size.x - corners.get_child(1).size.x / 2, -corners.get_child(1).size.y / 2)
	corners.get_child(2).position = Vector2(size.x - corners.get_child(2).size.x / 2, size.y - corners.get_child(2).size.y / 2)
	corners.get_child(3).position = Vector2(-corners.get_child(3).size.x / 2, size.y - corners.get_child(3).size.y / 2) 

# adds the corners.
func initialize() -> void:
	for i in 4:
		var c: ColorRect = CORNER.instantiate()
		corners.add_child(c)
		c.size = Vector2(dragger_width, dragger_width)
	

# returns true if any of the corners were selected.
func is_holded() -> bool:
	var result: bool = false
	for i in get_children():
		if i.holded:
			result = true
			break
	return result
	

func _show_corners() -> void:
	#print("show cal" + str(name))
	corners.show()


func _hide_corners() -> void:
	#print("hide" + str(name))
	corners.hide()

# handle the input of the main rectangle.
func _gui_input(event: InputEvent) -> void:
	if get_mode() == 0:
		return
	if event is InputEventScreenDrag:
		position += event.relative.rotated(rotation)
	if event is InputEventScreenTouch:
		if event.pressed:
			if get_tree().has_group("main"):
				var main = get_tree().get_first_node_in_group("main")
				main.set_current_rectangle(self)



# handle the input of the draggers.
func _on_handle_input(event: InputEvent, handle_id: int):
	if get_mode() == 0:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			# Start dragging
			handle_dragged = handle_id
			drag_start_pos = get_global_mouse_position()
			drag_start_size = size
		else:
			# Stop dragging
			handle_dragged = -1
	elif event is InputEventScreenDrag and handle_dragged == handle_id:
		if rotation == 0:
			_resize_rectangle(event.relative, handle_id)
	
