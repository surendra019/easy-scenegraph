extends PropertyManager

@onready var property_panel: Panel = $Panel2
@onready var component_list: ItemList = $Panel/AddComponent/CurrentOption/ItemList
@onready var current_component_label: Label = $Panel/AddComponent/CurrentOption
@onready var scene: Control = $Scene
@onready var message: Label = $Message
@onready var scene_name_edit: LineEdit = $Panel/Scene/Name/SceneNameEdit
@onready var info_window: Window = $InfoWindow
@onready var layer_toggle_btn: Button = $Panel2/LayerToggle
@onready var layer_manager: Panel = $Panel3
@onready var cursor_position: Label = $Panel/CursorPosition

@onready var _position_x: LineEdit = $Panel2/Position/LineEdit
@onready var _position_y: LineEdit = $Panel2/Position/LineEdit2
@onready var _rotation: LineEdit = $Panel2/Rotation/Rotation
@onready var _size_x: LineEdit = $Panel2/Size/Size_x
@onready var _size_y: LineEdit = $Panel2/Size/Size_y
@onready var output_window: Window = $Panel/Window
@onready var class_list: ItemList = $Panel/Scene/ExtendOption/CurrentOptionExtends/SceneExtendList
@onready var current_component_extend_label: Label = $Panel/Scene/ExtendOption/CurrentOptionExtends
@onready var output_label: RichTextLabel = $Panel/Window/ColorRect/VBoxContainer/RichTextLabel

@onready var node: Label = $Panel/Node
@onready var id_edit: LineEdit = $Panel/Node/Id/NodeIdEdit

const POSTER = preload("res://Scenes/Components/poster.tscn")
const BUTTON = preload("res://Scenes/Components/button.tscn")
const LABEL = preload("res://Scenes/Components/label.tscn")
const RECTANGLE = preload("res://Scenes/Components/rectangle.tscn")

const spawn_position := Vector2(200, 200)

var main_string: String
var current_component_index: int
var root_directory: String
var current_component_extend_index: int

var scene_name: String
var scene_extends: String

var last_selection_type: int = -1
var last_current_rectangle: Control

func _ready() -> void:
	message.hide()
	class_list.hide()
	class_list.auto_height = true
	component_list.hide()
	component_list.auto_height = true
	scene_extends = class_list.get_item_text(0)
	add_rectangle()


func _process(delta: float) -> void:
	handle_inputs()
	if Rect2(scene.position, scene.size).has_point(get_global_mouse_position()):
		cursor_position.show()
	else:
		cursor_position.hide()
	cursor_position.text = str(get_global_mouse_position())
	if scene.get_mode() == 0:
		if current_rectangle:
			last_current_rectangle = current_rectangle
		current_rectangle = null
		layer_manager.hide()
		layer_toggle_btn.text =  "^"
	else:
		if !current_rectangle && last_current_rectangle:
			current_rectangle = last_current_rectangle
	
	if current_rectangle:
		show_properties()
		id_edit.placeholder_text = str(current_rectangle.id)
		_position_x.placeholder_text = str(current_rectangle.position.x)
		_position_y.placeholder_text = str(current_rectangle.position.y)
		_size_x.placeholder_text = str(current_rectangle.size.x)
		_size_y.placeholder_text = str(current_rectangle.size.y)
		_rotation.placeholder_text = str(current_rectangle.rotation_degrees)
		
	else:
		hide_properties()


func handle_inputs() -> void:
	if Input.is_action_just_pressed("delete"):
		if scene.get_mode() == 0:
			show_message("cannot perform this action in test mode")
			return 
		delete_current_node()
		
	if Input.is_action_just_pressed("copy_node"):
		if scene.get_mode() == 0:
			show_message("cannot perform this action in test mode")
			return 
		if current_rectangle:
			Manager.copied_node = current_rectangle.duplicate()
			show_action("copy node")
			
	if Input.is_action_just_pressed("paste_node"):
		if scene.get_mode() == 0:
			show_message("cannot perform this action in test mode")
			return 
		paste_node()
		show_action("paste node")
		
	if Input.is_action_just_pressed("duplicate_node"):
		if scene.get_mode() == 0:
			show_message("cannot perform this action in test mode")
			return 
		if current_rectangle:
			Manager.copied_node = current_rectangle.duplicate()
			Manager.copied_node.component_type_idx = current_rectangle.component_type_idx
		var res : bool = paste_node(true)
		if res:
			show_action("duplicate node")
		
func show_action(s: String) -> void:
	show_message("[ACTION]: " + s)
	
# shows the text message at the top center of the screen.
func show_message(s: String) -> void:
	message.text = s
	message.show()
	await get_tree().create_timer(3).timeout
	message.hide()
	

# adds a rectangle.
func add_rectangle() -> void:
	var r: Control
	match current_component_index:
		0:
			r = POSTER.instantiate()
		1:
			r = BUTTON.instantiate()
		2:
			r = LABEL.instantiate()
		3: 
			r = RECTANGLE.instantiate()
	scene.add_child(r)
	layer_manager.add_layer(component_list.get_item_text(current_component_index), r)
	r.position = spawn_position
	r.component_type_idx = current_component_index
	current_rectangle = r

# paste the copied node in to position.
func paste_node(on_same_pos: bool = false) -> bool:
	if Rect2(scene.position, scene.size).has_point(get_global_mouse_position()):
		if Manager.copied_node:
			scene.add_child(Manager.copied_node)
			layer_manager.add_layer(component_list.get_item_text(current_component_index), Manager.copied_node)
			if !on_same_pos:
				Manager.copied_node.position = get_global_mouse_position()
			current_rectangle = Manager.copied_node
			Manager.copied_node = Manager.copied_node.duplicate()
			return true
			
	return false
	
	


func show_properties() -> void:
	for i in property_panel.get_children():
		i.show()
	node.show()

func hide_properties() -> void:
	for i in property_panel.get_children():
		i.hide()
	node.hide()


func set_current_rectangle(r: Control) -> void:
	current_rectangle = r
	scene.move_child(current_rectangle, -1)
	
func _on_current_option_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			component_list.show()


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	current_component_index = index
	current_component_label.text = component_list.get_item_text(index)
	component_list.hide()


func _on_add_component_button_pressed() -> void:
	if scene.get_mode() == 0:
		show_message("cannot perform this action in test mode")
		return
	add_rectangle()


	


func _on_line_edit_text_changed(new_text: String) -> void:
	if current_rectangle and new_text != "":
		current_rectangle.position.x = float(new_text)


func _on_line_edit_text_submitted(new_text: String) -> void:
	_position_x.placeholder_text = _position_x.text
	_position_x.text = ""
	_position_x.release_focus()
	


func _on_line_edit_2_text_changed(new_text: String) -> void:
	if current_rectangle and new_text != "":
		current_rectangle.position.y = float(new_text)


func _on_line_edit_2_text_submitted(new_text: String) -> void:
	_position_y.placeholder_text = _position_y.text
	_position_y.text = ""
	_position_y.release_focus()


func _on_size_x_text_changed(new_text: String) -> void:
	if current_rectangle and new_text != "":
		#print("changed")
		current_rectangle.size.x = float(new_text)


func _on_size_x_text_submitted(new_text: String) -> void:
	_size_x.placeholder_text = _size_x.text
	_size_x.text = ""
	_size_x.release_focus()


func _on_size_y_text_changed(new_text: String) -> void:
	if current_rectangle and new_text != "":
		current_rectangle.size.y = float(new_text)


func _on_size_y_text_submitted(new_text: String) -> void:
	_size_y.placeholder_text = _size_y.text
	_size_y.text = ""
	_size_y.release_focus()


func _on_rotation_text_changed(new_text: String) -> void:
	if current_rectangle and new_text != "":
		current_rectangle.rotation_degrees = (float(new_text))


func _on_rotation_text_submitted(new_text: String) -> void:
	_rotation.placeholder_text = _rotation.text
	_rotation.text = ""
	_rotation.release_focus()


func _on_delete_button_pressed() -> void:
	delete_current_node()


func delete_current_node() -> void:
	if scene.get_mode() == 0:
		show_message("cannot perform this action in test mode")
		return
	if current_rectangle:
		layer_manager.remove_layer(current_rectangle)
		scene.remove_child(current_rectangle)
		show_action("delete node")
		if scene.get_child_count() > 0:
			set_current_rectangle(scene.get_child(scene.get_child_count() - 1))
		else:
			current_rectangle = null
func _on_file_dialog_file_selected(path: String) -> void:
	if current_rectangle:
		current_rectangle.add_image((path))


func _on_select_root_folder_btn_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.show()


func _on_file_dialog_dir_selected(dir: String) -> void:
	root_directory = dir


func _on_expand_btn_pressed() -> void:
	if scene.get_mode() == 0:
		show_message("cannot perform this action in test mode")
		return
	if current_rectangle:
		current_rectangle.set_anchors_preset(Control.PRESET_FULL_RECT)
		current_rectangle.size = scene.size
		current_rectangle.rotation = 0
		current_rectangle.position = Vector2.ZERO

func _on_horizontal_center_btn_pressed() -> void:
	if scene.get_mode() == 1:
		if current_rectangle:
			current_rectangle.position.x = (scene.size.x - current_rectangle.size.x) / 2
	else:
		show_message("cannot perform this action in test mode")

func _on_vertical_center_btn_pressed() -> void:
	if scene.get_mode() == 1:
		if current_rectangle:
			current_rectangle.position.y = (scene.size.y - current_rectangle.size.y) / 2
	else:
		show_message("cannot perform this action in test mode")
		


func _on_window_close_requested() -> void:
	output_window.hide()


func _on_output_btn_pressed() -> void:
	main_string = ""
	if output_window.visible:
		return
	var result: String = scene.process_scene()
	if result == "":
		return
		
	show_message("success")
	result = scene.end_main_string(result)
	main_string = result
	output_label.text = result
	output_window.show()


func _on_copy_btn_pressed() -> void:
	DisplayServer.clipboard_set(main_string)


func _on_id_ok_btn_pressed() -> void:
	if scene.get_mode() == 1:
		if current_rectangle:
			if id_edit.text == "" && id_edit.placeholder_text == "":
				show_message("id cannot be empty")
				return
			id_edit.placeholder_text = id_edit.text
			current_rectangle.id = id_edit.text
			id_edit.text = ""
	else:
		show_message("cannot perform this action in test mode")



func _on_current_option_extends_gui_input(event: InputEvent) -> void:
	if scene.get_mode() == 1:
		if event is InputEventScreenTouch:
			if event.pressed:
				class_list.show()
	else:
		show_message("cannot perform this action in test mode")
		


func _on_scene_name_ok_btn_pressed() -> void:
	if scene_name_edit.text == "":
		show_message("scene name cannot be empty")
		return
	
	scene_name = scene_name_edit.text
	scene_name_edit.placeholder_text = scene_name_edit.text
	scene_name_edit.text = ""
	

func _on_scene_extend_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	current_component_extend_index = index
	current_component_extend_label.text = class_list.get_item_text(index)
	class_list.hide()
	scene_extends = class_list.get_item_text(index)
	


func _on_more_properties_btn_pressed() -> void:
	if current_rectangle.component_type_idx != -1:
		if last_selection_type != current_rectangle.component_type_idx:
			for i in more_properties_container.get_children():
				more_properties_container.remove_child(i)
				
			match current_rectangle.component_type_idx:
				0:
					add_poster_properties()
					add_group_properties()
				1:
					add_button_properties()
					add_group_properties()
				2:
					add_labelbase_properties()
					add_group_properties()
				3:
					add_rectangle_properties()
					add_group_properties()
			last_selection_type = current_rectangle.component_type_idx
		match current_rectangle.component_type_idx:
			0:
				set_group_properties()
				set_poster_properties()
			1:
				set_group_properties()
				set_button_properties()
			2:
				set_labelbase_properties()
				set_group_properties()
			3:
				set_rectangle_properties()
				set_group_properties()
	more_properties_window.show()
	more_properties_window_bg.show()



func _on_more_properties_window_close_requested() -> void:
	more_properties_window.hide()
	more_properties_window_bg.hide()


func _on_info_window_close_requested() -> void:
	info_window.hide()


func _on_layer_toggle_pressed() -> void:
	if layer_manager.visible:
		layer_manager.hide()
		layer_toggle_btn.text = "^"
	else:
		layer_manager.show()
		layer_toggle_btn.text = "-"


func _on_brs_pressed() -> void:
	print("show brs code")


func _on_xml_pressed() -> void:
	print("show xml code")
