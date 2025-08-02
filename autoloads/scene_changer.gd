extends CanvasLayer

@export var background_music: AudioStreamSynchronized

enum MainScenes {MAIN, WORLD}

const _MAIN_SCENES_PATHS = {
	MainScenes.MAIN: "res://scenes/main.tscn",
	MainScenes.WORLD: "res://scenes/world.tscn"
}

var _new_scene_path: String

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _bgm_player: AudioStreamPlayer = %BGMPlayer

func _ready() -> void:
	_bgm_player.stream = background_music
	_bgm_player.play()

## Interface to this autoload
func change_to(new_scene: MainScenes, transition: String = "fade_out_in") -> void:
	_new_scene_path = _MAIN_SCENES_PATHS[new_scene]
	
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play(transition)


## Called by the AnimationPlayer
func _change_scene_deferred():
	get_tree().call_deferred("change_scene_to_file", _new_scene_path)
	
	
#region music controls

var bgm_calm = 1
var bgm_action = 2

func set_action_music():
	_fade_music(bgm_action, 0, 1)

func set_calm_music():
	_fade_music(bgm_action, -30, 2)
	

func _fade_music(stream_index, volume: float, speed: float = 1):
	var tween = create_tween()

	tween.tween_method(
		func(volume_tween: float) -> void:
			background_music.set_sync_stream_volume(stream_index, volume_tween),
		background_music.get_sync_stream_volume(stream_index),
		volume, 
		speed
	)

#endregion 
