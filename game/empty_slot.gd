extends Node2D

signal pressed(index: int)

var index: int

func _on_texture_button_pressed() -> void:
	pressed.emit(index)
