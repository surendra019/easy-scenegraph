@tool
extends Label

class_name PropertyInput

@export var property_name: String


func _process(delta: float) -> void:
	text = property_name + ":"
