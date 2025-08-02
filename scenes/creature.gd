class_name Creature extends Node2D

signal mouse_entered
signal mouse_exited

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

var _currently_hovered: bool = false

@onready var _sfx_player: AudioStreamPlayer2D = $SFX_Player

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

func is_hovered():
	var mouse_pos = get_global_mouse_position()
	return %Sprite2D.get_rect().has_point(to_local(mouse_pos))

func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit()
	#print("Hovered over ", creature_name)

func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit()
	#print("Stopped hovering over ", creature_name)
