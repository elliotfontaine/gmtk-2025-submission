class_name Creature extends Node2D

var species: SpeciesResource:
	set(value):
		current_range = value.default_range
		%Sprite2D.texture = value.texture
		species = value
		#_sprite.position.y -= tex.get_height() * _sprite.scale.y /4

## Creature's name is displayed above it in a label
var creature_name: String:
	set(value):
		%Label.text = value
		name = value # Node.name
		creature_name = value

var current_range: int

@onready var _sfx_player: AudioStreamPlayer2D = $SFX_Player

func _ready() -> void:
	_sfx_player.stream = species.sfx_placed
	_sfx_player.play()
