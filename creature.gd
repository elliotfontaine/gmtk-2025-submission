extends Node2D
class_name Creature

@onready var label: Label = %Label

var data :SpeciesData

func _ready() -> void:
	label.text = name
