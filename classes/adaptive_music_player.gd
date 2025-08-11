class_name AdaptiveMusicPlayer extends Node

@export var always_on_music: AudioStreamMP3 = preload("res://assets/audio/music/bgm_always_on.mp3")
@export var calm_music: AudioStreamMP3 = preload("res://assets/audio/music/bgm_calm.mp3")
@export var action_music: AudioStreamMP3 = preload("res://assets/audio/music/bgm_action.mp3")


## If true, the sounds are paused. Setting [member stream_paused] to false resumes
## all sounds. Note: This property is automatically changed when exiting or entering
## the tree, or this node is paused (see Node.process_mode).
var stream_paused: bool:
	set(value):
		for child: AudioStreamPlayer in get_children():
			child.stream_paused = value
		stream_paused = value


## The target bus name. All sounds from this node will be playing on this bus.
## Note: At runtime, if no bus with the given name exists, all sounds will fall
## back on "Master". See also AudioServer.get_bus_name.
var bus: StringName = &"Music":
	set(value):
		for child: AudioStreamPlayer in get_children():
			child.bus = value
		bus = value


## If true, this node is playing sounds. Setting this property has the same effect
## as play and stop.
var playing: bool:
	set(value):
		if playing: play()
		else: stop()
	get():
		return get_child(0).playing


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
func tween_intensity(value: float, tween_time: float) -> void:
	value = clamp(value, 0.0, 1.0)
	if _current_stream_type == _StreamTypes.SYNC:
		_change_intensity_sync(value, tween_time)
	if _current_stream_type == _StreamTypes.THREE:
		_change_intensity_three(value, tween_time)


enum _StreamTypes {SYNC, THREE}

var _current_stream_type: _StreamTypes
var _tween := create_tween()


func _enter_tree() -> void:
	_current_stream_type = _StreamTypes.THREE if OS.has_feature("web") else _StreamTypes.SYNC


func _ready() -> void:
	if _current_stream_type == _StreamTypes.THREE:
		_add_three_children()
	else:
		_add_sync_child()
	# make sure to update the children's properties
	bus = bus
	playing = playing
	stream_paused = stream_paused


func _add_three_children() -> void:
	var stream_player_0 := AudioStreamPlayer.new()
	var stream_player_1 := AudioStreamPlayer.new()
	var stream_player_2 := AudioStreamPlayer.new()
	stream_player_0.stream = always_on_music
	stream_player_1.stream = calm_music
	stream_player_2.stream = action_music
	stream_player_0.play()
	for sp in [stream_player_0, stream_player_1, stream_player_2]:
		add_child(sp)


func _add_sync_child() -> void:
	var stream_player := AudioStreamPlayer.new()
	var audio_stream_sync := AudioStreamSynchronized.new()
	audio_stream_sync.set_sync_stream(0, always_on_music)
	audio_stream_sync.set_sync_stream(1, always_on_music)
	audio_stream_sync.set_sync_stream(2, always_on_music)
	stream_player.stream = audio_stream_sync
	add_child(stream_player)


func _change_intensity_sync(value: float, tween_time: float) -> void:
	_tween.stop() # reset the tween to its initial state
	var sync_stream: AudioStreamSynchronized = get_child(0).stream

	var _set_sync_stream_linear_volume := func(stream_index: int, volume_linear: float) -> void:
		sync_stream.set_sync_stream_volume(stream_index, linear_to_db(volume_linear))

	var _get_sync_stream__linear_volume := func(stream_index: int) -> void:
		return db_to_linear(sync_stream.get_sync_stream_volume(stream_index))

	_tween.tween_method(
		_set_sync_stream_linear_volume.call(1, _calculate_calm_linear_volume(value)),
		_get_sync_stream__linear_volume.call(1),
		value,
		tween_time
	)

	_tween.tween_method(
		_set_sync_stream_linear_volume.call(2, _calculate_action_linear_volume(value)),
		_get_sync_stream__linear_volume.call(2),
		value,
		tween_time
	)


func _change_intensity_three(value: float, tween_time: float) -> void:
	_tween.stop() # reset the tween to its initial state
	var calm_stream_player: AudioStreamPlayer = get_child(0).get_child(1)
	var action_stream_player: AudioStreamPlayer = get_child(0).get_child(2)
	_tween.tween_property(calm_stream_player, "volume_linear", _calculate_calm_linear_volume(value), tween_time)
	_tween.tween_property(action_stream_player, "volume_linear", _calculate_action_linear_volume(value), tween_time)


func _calculate_calm_linear_volume(intensity: float) -> float:
	return clamp(intensity * 2, 0.0, 1.0)


func _calculate_action_linear_volume(intensity: float) -> float:
	return clamp((intensity - 0.5) * 2, 0.0, 1.0)