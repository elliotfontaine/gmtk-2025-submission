@tool
extends Control
class_name ShopItem

@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var texture_button: TextureButton = %TextureButton

signal pressed

@export var species: SpeciesResource:
	set(value):
		species = value
		%CreatureSprite.texture = value.texture if value != null else null

@export var price: int = 101:
	get: return int(%Price.text)
	set(value): %Price.text = str(value)

var sold :bool = false:
	set(val):
		sold = val
		if val:
			h_box_container.hide()
			texture_button.hide()


func _on_texture_button_pressed() -> void:
	if not sold:
		pressed.emit()
