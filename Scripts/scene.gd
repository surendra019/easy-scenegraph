extends Control

@onready var test_btn: Button = $"../Panel/TestBtn"

enum MODE {TEST, EDIT}
var current_mode: MODE = MODE.EDIT


func set_mode(mode: MODE) -> void:
	current_mode = mode

func get_mode() -> int:
	return current_mode
	
func _on_test_btn_pressed() -> void:
	if current_mode == MODE.EDIT:
		set_mode(MODE.TEST)
		test_btn.text = "Edit"
	else:
		set_mode(MODE.EDIT)
		test_btn.text = "Test"
