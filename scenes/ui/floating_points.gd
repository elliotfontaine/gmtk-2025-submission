extends Control

enum PointTypes {SCORE, MONEY}

const POINT_ICONS: Dictionary = {
	PointTypes.SCORE: preload("res://assets/sprites/ui/small_trophy.png"),
	PointTypes.MONEY: preload("res://assets/sprites/ui/money.png")
}

@export_group("Points")
@export var points_count: int = 1
@export var point_type: PointTypes = PointTypes.SCORE
@export_group("Animation")
@export var move_distance: float = 100.0
@export var duration: float = 1.5

@onready var label: Label = %Label
@onready var icon: TextureRect = %Icon

func _ready() -> void:
	label.text = "+%d" % points_count
	icon.texture = POINT_ICONS[point_type]
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - move_distance, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(Callable(self, "queue_free"))
	# optionally: await tween.finished; queue_free()
