extends Node2D
class_name Creature
@onready var sfx_player: AudioStreamPlayer2D = $SFX_Player

@onready var label: Label = %Label
@onready var sprite: Sprite2D = %Sprite2D

var species: SpeciesResource:
	set(value):
		current_range = value.default_range
		species = value

var current_range: int

func _ready() -> void:
	label.text = name
	sfx_player.stream = species.sfx_placed
	sfx_player.play()

func do_eat() -> void:
	sfx_player.stream = species.sfx_eat
	sfx_player.play()

func set_texture() -> void:
	var tex :CompressedTexture2D = species.texture
	sprite.texture = tex
	#sprite.position.y -= tex.get_height() * sprite.scale.y /4
