extends Node
## Manager autoload  (singleton) for custom mouse cursors.
##
## Textures should be defined in the [member CURSORS_TEXTURES] constant dictionary.
## A scale factor can be set in [member CURSOR_SCALE_FACTOR]
## Cursors are automatically resized based on the scale factor and the game window size.

## Scale factor used for cursor size. Another factor used for the final size is the main window height.
const CURSOR_SCALE_FACTOR: float = 0.02

## Paths to the cursor textures. Keys should be from [enum Input.CursorShape]
const CURSORS_TEXTURES: Dictionary = {
	Input.CURSOR_ARROW: preload("res://assets/sprites/ui/cursors/mouse_cursor_arrow.png"),
	Input.CURSOR_POINTING_HAND: preload("res://assets/sprites/ui/cursors/mouse_cursor_pointing_hand.png"),
	Input.CURSOR_DRAG: preload("res://assets/sprites/ui/cursors/mouse_cursor_pointing_hand_grab.png"),
}

func _ready():
	get_tree().root.size_changed.connect(_on_main_window_resized)
	_on_main_window_resized()

func _on_main_window_resized() -> void:
	var cursor_final_size := int(get_tree().root.size.y * CURSOR_SCALE_FACTOR)
	for cursor_shape in CURSORS_TEXTURES.keys():
		set_sized_cursor(CURSORS_TEXTURES[cursor_shape], cursor_shape, cursor_final_size)

## Sets a custom mouse cursor image, which is only visible inside the game's window. Compared to
## [method Input.set_custom_mouse_cursor], you can pass down the cursor final [param size].[br]
## [param texture] should be squared shape from the start. 
func set_sized_cursor(texture: Texture2D, shape: Input.CursorShape, size: int, hotspot: Vector2 = Vector2.ZERO) -> void:
	var image := texture.get_image()
	image.resize(size, size, Image.INTERPOLATE_LANCZOS)
	Input.set_custom_mouse_cursor(
		image,
		shape,
		hotspot
	)
