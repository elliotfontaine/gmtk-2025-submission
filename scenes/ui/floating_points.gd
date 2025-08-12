class_name FloatingPoint extends Control

enum PointTypes {SCORE, MONEY}

const POINT_ICONS: Dictionary = {
	PointTypes.SCORE: preload("res://assets/sprites/ui/small_trophy.png"),
	PointTypes.MONEY: preload("res://assets/sprites/ui/money.png")
}

@export var move_distance: float = 50.0
@export var duration: float = 1.0
@export var default_icon: Texture2D

@onready var label: Label = %Label
@onready var icon: TextureRect = %Icon


func set_points(points: int, point_type: PointTypes = PointTypes.SCORE) -> void:
	label.text = "+%d" % points
	icon.texture = POINT_ICONS[point_type]

func _ready() -> void:
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - move_distance, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(Callable(self, "queue_free"))
	# optionally: await tween.finished; queue_free()
