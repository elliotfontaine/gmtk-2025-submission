extends Node2D
class_name Creature

@onready var label: Label = %Label

var species: SpeciesResource

func _ready() -> void:
	label.text = name
