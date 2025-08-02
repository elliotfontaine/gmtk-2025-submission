extends Node2D
class_name Slot

const SLOT = preload("res://assets/sprites/slot.png")

signal pressed(index: int)
signal hovered(slot: Slot)
signal unhovered(slot: Slot)

var index: int

#@onready var sprite: Sprite2D = %Sprite2D

func _on_texture_button_pressed() -> void:
	pressed.emit(index)

func _on_texture_button_mouse_entered() -> void:
	hovered.emit(self)

func _on_texture_button_mouse_exited() -> void:
	unhovered.emit(self)


##to be set to a creature's sprite
#func set_texture(tex:CompressedTexture2D):
	#sprite.texture = tex
	#sprite.scale = Vector2(0.8,0.8)
	#sprite.modulate = Color.html("a9dfd799")

##to go back to the slot
#func reset_texture() -> void:
	#sprite.texture = SLOT
	#sprite.scale = Vector2(1.0,1.0)
	#sprite.modulate = Color.WHITE
