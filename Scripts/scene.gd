extends Control

@onready var test_btn: Button = $"../Panel/TestBtn"

enum MODE {TEST, EDIT}
var current_mode: MODE = MODE.EDIT

const xml_starting: String = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\n"

var main_ref: Control

func _ready() -> void:
	main_ref = get_parent()
	
func set_mode(mode: MODE) -> void:
	current_mode = mode

func get_mode() -> int:
	return current_mode

# adds the starting lines.
func initialize_file() -> String:
	var main_string : String = ""
	main_string += xml_starting
	if main_ref.scene_name == "":
		main_ref.show_message("scene name cannot be empty")
		return ""
	if main_ref.scene_extends == "":
		main_ref.show_message("scene should extend a class")
		return ""
	main_string += get_component_starting(main_ref.scene_name, main_ref.scene_extends)
	main_string += get_script_line(main_ref.scene_name + ".brs")
	main_string += "\t<children>\n"
	return main_string

# returns the component starting tag by setting the variable.
func get_component_starting(_name: String, _extends: String) -> String:
	return "<component name=\"" + _name + "\" " + "extends=\"" + _extends + "\">\n"

# returns the script line to attach.
func get_script_line(_uri: String) -> String:
	return "\t<script type=\"text/brightscript\" uri=\"" + _uri + "\"/>\n" 

# ends the main string by closing the tags.
func end_main_string(main_string: String) -> String:
	print(main_string)
	main_string += "\t</children>\n"
	main_string += "</component>"
	return main_string


# processes the complete scene and generate the xml string.
func process_scene() -> String:
	var main_string: String = initialize_file()
	if main_string == "":
		return main_string
	for i in get_children():
		if i.id == "":
			main_ref.show_message("id cannot be empty")
			return ""
		match i.component_type_idx:
			0:
				main_string += "\t\t<Poster\n"
				main_string += "\t\t\turi=\"" + i.uri + "\"\n"
				main_string += "\t\t\twidth=\"" + str(i.size.x) + "\"\n"
			1:
				main_string += "\t\t<Button\n"
				main_string += "\t\t\tminWidth=\"" + str(i.size.x) + "\"\n"
				main_string += "\t\t\tmaxWidth=\"" + str(i.size.x) + "\"\n"
				if i.normal_uri != "":
					main_string += "\t\t\tshowFocusFootprint=\"true\"\n"
					main_string += "\t\t\tfocusFootprintBitmapUri=\"" + i.normal_uri + "\"\n"
				if i.focused_uri != "":
					main_string += "\t\t\tfocusBitmapUri=\"" + i.focused_uri + "\"\n"
				if i.text != "":
					main_string += "\t\t\ttext=\"" + (i.text.trim_suffix("   ")) + "\"\n"
			2: 
				main_string += "\t\t<Label\n"
				main_string += "\t\t\ttext=\"" + (i.text.trim_suffix("   ")) + "\"\n"
				main_string += "\t\t\tcolor=\"" + color_to_argb32(i.color) + "\"\n"
			3:
				main_string += "\t\t<Rectangle\n"
				main_string += "\t\t\tcolor=\"" + color_to_argb32(i.color) + "\"\n"
				main_string += "\t\t\twidth=\"" + str(i.size.x) + "\"\n"
				

		main_string += "\t\t\tid=\"" + i.id + "\"\n"
		main_string += "\t\t\tvisible=\"" + str(i.visible) + "\"\n"
		main_string += "\t\t\topacity=\"" + str(i.modulate.a) + "\"\n" 
		main_string += "\t\t\trotation=\"" + str(-i.rotation) + "\"\n"
		main_string += "\t\t\theight=\"" + str(i.size.y) + "\"\n"
		main_string += "\t\t\ttranslation=\"[" + str(i.position.x) + "," + str(i.position.y) + "]\"\n"
		main_string += "\t\t/>\n"
	return main_string


func color_to_argb32(color: Color) -> String:
	var alpha = int(color.a * 255) << 24
	var red = int(color.r * 255) << 16
	var green = int(color.g * 255) << 8
	var blue = int(color.b * 255)
	return "0x%08X" % (alpha | red | green | blue)

func _on_test_btn_pressed() -> void:
	if current_mode == MODE.EDIT:
		set_mode(MODE.TEST)
		test_btn.text = "Edit"
	else:
		set_mode(MODE.EDIT)
		test_btn.text = "Test"
