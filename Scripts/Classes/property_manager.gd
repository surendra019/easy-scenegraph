extends Control

class_name PropertyManager


const BUTTON_PROPERTIES = preload("res://Scenes/More Properties/button_properties.tscn")
const GROUP_PROPERTIES = preload("res://Scenes/More Properties/group_properties.tscn")
const POSTER_PROPERTIES = preload("res://Scenes/More Properties/poster_properties.tscn")
const LABELBASE_PROPERTIES = preload("res://Scenes/More Properties/labelbase_properties.tscn")
const RECTANGLE_PROPERTIES = preload("res://Scenes/More Properties/rectangle_properties.tscn")

@onready var more_properties_container: VBoxContainer = $Info/MorePropertiesWind/ColorRect/ScrollContainer/Container
@onready var more_properties_window_bg: ColorRect = $Info
@onready var more_properties_window: Window = $Info/MorePropertiesWind

@onready var file_dialog: FileDialog = $FileDialog

var current_rectangle: Control

# sets the Button class properties.
func set_button_properties() -> void:
	var p = get_tree().get_first_node_in_group("button_properties")
	if current_rectangle:
		p._set_min_width(current_rectangle.min_width)
		p._set_max_width(current_rectangle.max_width)
		p._set_focused_uri(current_rectangle.focused_uri)
		p._set_normal_uri(current_rectangle.normal_uri)
		p._set_text(current_rectangle.text)
	p._min_width_changed.connect(func(val: float):
		if current_rectangle:
			current_rectangle.min_width = val
			if current_rectangle.size.x < val:
				current_rectangle.size.x = val
		)
	p._max_width_changed.connect(func(val: float):
		if current_rectangle:
			current_rectangle.max_width = val
			if current_rectangle.size.x > val:
				current_rectangle.size.x = val
		)
	p._focused_uri_changed.connect(func(val: String):
		if current_rectangle && current_rectangle.last_focused_uri != "pkg:/images/" + val.get_file():
			current_rectangle.last_focused_uri = "pkg:/images/" + val.get_file()
			current_rectangle.set_focused_image(val)
		)
	p._normal_uri_changed.connect(func(val: String):
		if current_rectangle && current_rectangle.last_normal_uri != "pkg:/images/" + val.get_file():
			current_rectangle.last_normal_uri = "pkg:/images/" + val.get_file()
			current_rectangle.set_normal_image(val)
		)
	p._text_changed.connect(func(val: String):
		print("called")
		if current_rectangle:
			current_rectangle.set_text(val)
		)
	p._text_deleted.connect(func():
		if current_rectangle:
			if current_rectangle.text_label:
				current_rectangle.remove_child(current_rectangle.text_label)
				current_rectangle.text_label = null
				get_tree().get_first_node_in_group("main").show_message("removed text")
				
		)
		
	
func add_button_properties() -> void:
	var p: Control = BUTTON_PROPERTIES.instantiate()
	more_properties_container.add_child(p)

func add_poster_properties() -> void:
	var p: Control = POSTER_PROPERTIES.instantiate()
	more_properties_container.add_child(p)

func add_rectangle_properties() -> void:
	var p: Control = RECTANGLE_PROPERTIES.instantiate()
	more_properties_container.add_child(p)
	
func add_labelbase_properties() -> void:
	var p: Control = LABELBASE_PROPERTIES.instantiate()
	more_properties_container.add_child(p)


func set_rectangle_properties() -> void:
	var p: Control = get_tree().get_first_node_in_group("rectangle_properties")
	if !current_rectangle:
		return
	p._set_color(current_rectangle.color)
	p._color_changed.connect(func(val: Color):
		current_rectangle.set_color(val)
		)
	
func set_labelbase_properties() -> void:
	var p: Control = get_tree().get_first_node_in_group("labelbase_properties")
	if !current_rectangle:
		return
	p._set_text(current_rectangle.text)
	p._set_color(current_rectangle.color)
	p._text_changed.connect(func(val: String):
		current_rectangle.set_text(val)
		)
	p._text_deleted.connect(func():
		current_rectangle.remove_text()
		)
	p._color_changed.connect(func(val: Color):
		current_rectangle.set_text_color(val)
		)
		
func set_poster_properties() -> void:
	var p = get_tree().get_first_node_in_group("poster_properties")
	if current_rectangle:
		p._set_uri(current_rectangle.uri)
	var handle_uri_changed: Callable = func(val: String):
		if current_rectangle && current_rectangle.last_uri != "pkg:/images/" + val.get_file():
			current_rectangle.last_uri = "pkg:/images/" + val.get_file()
			current_rectangle.add_image(val)
	if !p._uri_changed.is_connected(handle_uri_changed):
		p._uri_changed.connect(handle_uri_changed)
	
# sets the Group class properties.
func set_group_properties() -> void:
	var p = get_tree().get_first_node_in_group("group_properties")
	if current_rectangle:
		p._set_visible(current_rectangle.visible)
		p._set_opacity(current_rectangle.modulate.a)
	p._visiblity_changed.connect(func(v: bool):
		if current_rectangle:
			current_rectangle.visible = v
		)
	p._opacity_changed.connect(func(o: float):
		if current_rectangle:
			current_rectangle.modulate.a = o
		)
		
# adds the group specific properties to the window.
func add_group_properties() -> void:
	var p: Control = GROUP_PROPERTIES.instantiate()
	more_properties_container.add_child(p)
	
	
