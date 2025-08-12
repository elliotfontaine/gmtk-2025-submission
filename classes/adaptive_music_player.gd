@tool
class_name AdaptiveMusicPlayer extends Node

## This AudioStreamSynchronized should have 3 tracks, ordered that way: [br]
## - "always playing" [br]
## - "calm" [br]
## - "action"
@export var synced_music: AudioStreamSynchronized = preload("res://audio/bgm_synchronized.tres")


## If true, this node is playing sounds. Setting this property has the same effect
## as play and stop.
@export var playing: bool:
	set(value):
		if value: play()
		else: stop()
	get:
		return get_child(0).playing


## If true, the sounds are paused. Setting [member stream_paused] to false resumes
## all sounds.
@export var stream_paused: bool:
	set(value):
		for child: AudioStreamPlayer in get_children():
			child.stream_paused = value
	get:
		return get_child(0).stream_paused


## The target bus name. All sounds from this node will be playing on this bus.
## Note: At runtime, if no bus with the given name exists, all sounds will fall
## back on "Master". See also AudioServer.get_bus_name.
enum AudioBus {Master = 0}
@export var bus: AudioBus:
	set(value):
		for child: AudioStreamPlayer in get_children():
			child.bus = AudioServer.get_bus_name(bus)
		bus = value


## Plays the music from the beginning, or the given from_position in seconds.
func play(from_position: float = 0.0) -> void:
	for child: AudioStreamPlayer in get_children():
		child.play(from_position)


## Stops all sounds from this node.
func stop() -> void:
	for child: AudioStreamPlayer in get_children():
		child.stop()


## Set the adaptive music intensity. [parameter value] will be clamped to 0.0 - 1.0.
## At 0.0, only the "always_playing" track will be active. From 0.0 to 0.5, the
## "calm" track will activate and progressively get more intense. From 0.5 to 1.0,
## the "action" track will activate and progressively get more intense.
func tween_intensity(value: float, tween_time: float = 1.0) -> void:
	value = clamp(value, 0.0, 1.0)
	if _current_stream_type == _StreamTypes.SYNC:
		_change_intensity_sync(value, tween_time)
	if _current_stream_type == _StreamTypes.THREE:
		_change_intensity_three(value, tween_time)


enum _StreamTypes {SYNC, THREE}
var _current_stream_type: _StreamTypes
	

func _ready() -> void:
	_current_stream_type = _StreamTypes.THREE if OS.has_feature("web") else _StreamTypes.SYNC
	if _current_stream_type == _StreamTypes.THREE:
		_add_three_children()
	else:
		_add_sync_child()
	# make sure to update the children's properties
	bus = bus
	playing = playing
	stream_paused = stream_paused


func _add_three_children() -> void:
	for i in [0, 1, 2]:
		var stream_player := AudioStreamPlayer.new()
		stream_player.stream = synced_music.get_sync_stream(i)
		stream_player.volume_db = synced_music.get_sync_stream_volume(i)
		add_child(stream_player)


func _add_sync_child() -> void:
	var stream_player := AudioStreamPlayer.new()
	stream_player.stream = synced_music
	add_child(stream_player)


func _change_intensity_sync(intensity: float, tween_time: float) -> void:
	var tween_1 = create_tween()
	var tween_2 = create_tween()
	var sync_stream: AudioStreamSynchronized = get_child(0).stream
	
	var _set_sync_stream_volume := func(volume_linear: float, stream_index: int) -> void:
		var volume_db = clamp(linear_to_db(volume_linear), -80.0, 0.0)
		sync_stream.set_sync_stream_volume(stream_index, volume_db)
	
	var _get_sync_stream_volume := func(stream_index: int) -> float:
		var volume_db = sync_stream.get_sync_stream_volume(stream_index)
		return db_to_linear(volume_db)
	
	var new_calm_linear = _calculate_calm_linear_volume(intensity)
	var new_action_linear = _calculate_action_linear_volume(intensity)
	
	tween_1.tween_method(
		_set_sync_stream_volume.bind(1),
		_get_sync_stream_volume.call(1),
		new_calm_linear,
		tween_time
	)
	
	tween_2.tween_method(
		_set_sync_stream_volume.bind(2),
		_get_sync_stream_volume.call(2),
		new_action_linear,
		tween_time
	)


func _change_intensity_three(intensity: float, tween_time: float) -> void:
	var tween = create_tween()
	var calm_stream_player: AudioStreamPlayer = get_child(1)
	var action_stream_player: AudioStreamPlayer = get_child(2)
	tween.tween_property(calm_stream_player, "volume_linear", _calculate_calm_linear_volume(intensity), tween_time)
	tween.tween_property(action_stream_player, "volume_linear", _calculate_action_linear_volume(intensity), tween_time)


func _calculate_calm_linear_volume(intensity: float) -> float:
	return clamp(intensity * 2, 0.0, 1.0)


func _calculate_action_linear_volume(intensity: float) -> float:
	return clamp((intensity - 0.5) * 2, 0.0, 1.0)


func _validate_property(property: Dictionary):
	if property.name == "bus":
		var busNumber = AudioServer.bus_count
		var options = ""
		for i in busNumber:
			if i > 0:
				options += ","
			var busName = AudioServer.get_bus_name(i)
			options += busName
		property.hint_string = options
