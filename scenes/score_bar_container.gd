extends CenterContainer
class_name ScoreBarContainer

@export var current_score :int:
	set(val):
		current_score = val
		_update_trophy_state()

@export var max_score :int:
	set(val):
		max_score = val
		_update_trophy_state()

## value between 0 and 100
var _score_display :float = 0.0

@onready var progress_bar_score: ProgressBar = %ProgressBarScore
@onready var label_score: Label = %LabelScore
@onready var animation_player_score_bar: AnimationPlayer = %AnimationPlayerScoreBar

func _update_trophy_state() -> void:
	if current_score >= max_score and current_score != 0:
		if animation_player_score_bar.assigned_animation not in [&"winning", &"winning_idle"]:
			animation_player_score_bar.play(&"winning")
			animation_player_score_bar.queue(&"winning_idle")
	else:
		animation_player_score_bar.play(&"RESET", 0.5)

func _process(delta: float) -> void:
	var display_target = clamp((current_score / float(max_score)) * 100.0, 0.0, 100.0)
	if _score_display != display_target:
		
		var lerp_speed :float
		if _score_display < display_target:
			lerp_speed = 3.0
		else:
			lerp_speed = 6.0
		_score_display = lerp(_score_display, float(display_target), lerp_speed * delta)
		
		label_score.text = "SCORE: %s / %s" % [roundi(current_score), max_score]
		progress_bar_score.value = roundi(_score_display)
