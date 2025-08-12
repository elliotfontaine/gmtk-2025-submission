extends CenterContainer
class_name ScoreBarContainer

@export var score_current :int:
	set(val):
		score_current = val
		_update_display()

@export var score_target :int:
	set(val):
		score_target = val
		_update_display()

var score_display :float = 0.0

@onready var progress_bar_score: ProgressBar = %ProgressBarScore
@onready var label_score: Label = %LabelScore
@onready var animation_player_score_bar: AnimationPlayer = %AnimationPlayerScoreBar

func _update_display() -> void:
	progress_bar_score.max_value = score_target
	#label_score.text = "SCORE: %s / %s" % [score_current, score_target]
	#progress_bar_score.value = score_current
	
	if score_current >= score_target and score_current != 0:
		if animation_player_score_bar.assigned_animation not in [&"winning", &"winning_idle"]:
			animation_player_score_bar.play(&"winning")
			animation_player_score_bar.queue(&"winning_idle")
	else:
		animation_player_score_bar.play(&"RESET", 0.5)

func _process(delta: float) -> void:
	if score_display != score_current:
		
		var lerp_speed :float
		if score_display < score_current:
			lerp_speed = 2.0
		else:
			lerp_speed = 6.0
		score_display = lerp(score_display, float(score_current), lerp_speed * delta)
		
		label_score.text = "SCORE: %s / %s" % [int(score_display), score_target]
		progress_bar_score.value = int(score_display)
