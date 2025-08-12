extends CanvasLayer

enum MainScenes {MAIN, WORLD}

const _MAIN_SCENES_PATHS = {
	MainScenes.MAIN: "res://scenes/main_menu.tscn",
	MainScenes.WORLD: "res://scenes/world.tscn"
}

const _MAIN_SCENES_DEFAULT_MUSIC_INTENSITY = {
	MainScenes.MAIN: 0.0,
	MainScenes.WORLD: 0.5
}

var _new_scene_path: String
var _new_scene_music_intensity: float

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var adaptive_music_player: AdaptiveMusicPlayer = %AdaptiveMusicPlayer

func _ready() -> void:
	adaptive_music_player.play()

## Interface to this autoload
func change_to(new_scene: MainScenes, transition: String = "fade_out_in") -> void:
	_new_scene_path = _MAIN_SCENES_PATHS[new_scene]
	_new_scene_music_intensity = _MAIN_SCENES_DEFAULT_MUSIC_INTENSITY[new_scene]
	
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play(transition)


## Called by the AnimationPlayer
func _change_scene_deferred():
	get_tree().call_deferred("change_scene_to_file", _new_scene_path)

## Called by the AnimationPlayer
func _set_music_intensity():
	adaptive_music_player.tween_intensity(_new_scene_music_intensity, 1.0)
