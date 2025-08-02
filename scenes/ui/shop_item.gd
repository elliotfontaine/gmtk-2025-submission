@tool
extends Control

signal pressed

@export var species: SpeciesResource:
	set(value):
		species = value
		%CreatureSprite.texture = value.texture if value != null else null

@export var price: int = 101:
	get: return int(%Price.text)
	set(value): %Price.text = str(value)

func _on_texture_button_pressed() -> void:
	pressed.emit()
