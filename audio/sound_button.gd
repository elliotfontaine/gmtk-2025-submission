extends Button
class_name SoundButton

# Optional: Add sound-playing logic
@export var click_sound: AudioStream

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_pressed():
	if click_sound:
		var sound = AudioStreamPlayer.new()
		sound.stream = click_sound
		sound.bus = "SFX"
		add_child(sound)
		sound.play()
