extends Node2D
class_name Creature
@onready var sfx_player: AudioStreamPlayer2D = $SFX_Player

@onready var label: Label = %Label

var species: SpeciesResource:
	set(value):
		current_range = value.default_range
		species = value

var current_range: int

func _ready() -> void:
	label.text = name
	sfx_player.stream = species.sfx_placed
	sfx_player.play()
