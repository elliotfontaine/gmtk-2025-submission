extends CanvasLayer

enum MainScenes {HOME, MAIN}

const _MAIN_SCENES_PATHS = {
	MainScenes.HOME: "res://scenes/home.tscn",
	MainScenes.MAIN: "res://scenes/main.tscn"
}

var _new_scene_path: String
var _new_bgm: AudioStream

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _bgm_player: AudioStreamPlayer = %BGMPlayer
@onready var _startup_bgm = get_tree().current_scene.get("background_music")

func _ready() -> void:
	# If the startup scene has a background music, play it
	_bgm_player.stream = _startup_bgm
	_bgm_player.play()

## Interface to this autoload
func change_to(new_scene: MainScenes, transition: String = "fade_out_in") -> void:
	_new_scene_path = _MAIN_SCENES_PATHS[new_scene]
	_new_bgm = _get_scene_bgm(_new_scene_path)
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play(transition)
	# If the new scene has the same background music, don't change it
	# Would need its own animation player to handle transitions
	if _bgm_player.stream == _new_bgm:
		return
	_bgm_player.stop()
	_bgm_player.stream = _new_bgm
	_bgm_player.play()

## Called by the AnimationPlayer
func _change_scene_deferred():
	get_tree().call_deferred("change_scene_to_file", _new_scene_path)

## Returns the background music of a scene saved on file
func _get_scene_bgm(new_scene_path: String) -> AudioStream:
	var new_scene = load(new_scene_path) as PackedScene
	var music: AudioStream = null
	var instance = new_scene.instantiate()
	if "background_music" in instance:
		# `get` will return null if background_music is not set
		music = instance.get("background_music")
	else:
		print_debug("No background music found in ", new_scene)
	instance.queue_free()
	return music
