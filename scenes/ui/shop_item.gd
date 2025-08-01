extends Control

signal pressed

var species: SpeciesResource

var sprite: Texture:
	get: return %CreatureSprite.texture
	set(value): %CreatureSprite.texture = value

var price: int:
	get: return int(%Price.text)
	set(value): %Price.text = str(value)

func _on_texture_button_pressed() -> void:
	pressed.emit()
