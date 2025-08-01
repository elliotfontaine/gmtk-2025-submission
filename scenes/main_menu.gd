extends Control
@onready var sfx_accept: AudioStreamPlayer2D = $SFX_Accept
@export var background_music: AudioStream


func _on_button_play_pressed() -> void:
	SceneChanger.change_to(SceneChanger.MainScenes.WORLD)
	sfx_accept.play()
