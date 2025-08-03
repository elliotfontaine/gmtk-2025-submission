@tool
class_name VolumeSlider extends HSlider

enum AudioBus {Master = 0}
@export var audio_bus: AudioBus = 0 as AudioBus
@onready var bus_name: String = AudioServer.get_bus_name(audio_bus)

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus)) * 100

func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus, linear_to_db(new_value / 100))

func _validate_property(property: Dictionary):
	if property.name == "audio_bus":
		var busNumber = AudioServer.bus_count
		var options = ""
		for i in busNumber:
			if i > 0:
				options += ","
			var busName = AudioServer.get_bus_name(i)
			options += busName
		property.hint_string = options
