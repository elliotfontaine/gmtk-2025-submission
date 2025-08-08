@tool
class_name ShopItem extends Control

const no_bg = preload("res://assets/sprites/ui/creature_background.png")
const common_bg = preload("res://assets/sprites/ui/rarity_common.png")
const uncommon_bg = preload("res://assets/sprites/ui/rarity_uncommon.png")
const rare_bg = preload("res://assets/sprites/ui/rarity_rare.png")

@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var texture_button: TextureButton = %TextureButton

signal pressed

@export var species: SpeciesResource:
	set(value):
		species = value
		%CreatureSprite.texture = value.texture if value != null else null
		if value == null:
			%CreatureBackground.texture = no_bg
		else:
			match value.rarity:
				Constants.RARITIES.COMMON:
					%CreatureBackground.texture = common_bg
				Constants.RARITIES.UNCOMMON:
					%CreatureBackground.texture = uncommon_bg
				Constants.RARITIES.RARE:
					%CreatureBackground.texture = rare_bg
				_:
					%CreatureBackground.texture = no_bg

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
