class_name Creature extends Node2D

signal mouse_entered
signal mouse_exited

@onready var tween_pos :Tween
@onready var _sfx_player: AudioStreamPlayer2D = $SFX_Player
@onready var arrow: Sprite2D = %Arrow

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

var target_position :Vector2:
	set(val):
		target_position = val
		tween_position(val)

func tween_position(target_pos:Vector2) -> void:
	if tween_pos and tween_pos.is_running():
		tween_pos.stop()
	tween_pos = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_pos.tween_property(self, "position", target_pos, 0.3)

func _ready() -> void:
	_sfx_player.stream = species.sfx_placed
	_sfx_player.play()

func do_eat() -> void:
	_sfx_player.stream = species.sfx_eat
	_sfx_player.play()

func is_hovered():
	var mouse_pos = get_global_mouse_position()
	return %Sprite2D.get_rect().has_point(to_local(mouse_pos))

func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit()
	#print("Hovered over ", creature_name)

func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit()
	#print("Stopped hovering over ", creature_name)

func show_arrow(show:bool):
	arrow.visible = show
