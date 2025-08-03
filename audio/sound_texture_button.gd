extends TextureButton
class_name SoundTextureButton

# Optional: Add sound-playing logic
@export var click_sound: AudioStream

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if click_sound:
		var sound = AudioStreamPlayer.new()
		sound.stream = click_sound
		sound.bus = "SFX"
		add_child(sound)
		sound.play()
