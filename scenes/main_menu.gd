extends Control

@onready var settings_menu: Control = %SettingsMenu

func _on_button_play_pressed() -> void:
	SceneChanger.change_to(SceneChanger.MainScenes.WORLD)

func _on_settings_button_pressed() -> void:
	settings_menu.show()
