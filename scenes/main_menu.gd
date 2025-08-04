extends Control

@onready var settings_menu: Control = %SettingsMenu
@onready var version_tag: Label = %VersionTag

func _ready() -> void:
	var project_version: String = ProjectSettings.get_setting("application/config/version")
	if project_version != "":
		version_tag.text = "vers. " + project_version
	else:
		version_tag.text = "Unknown version"

func _on_button_play_pressed() -> void:
	SceneChanger.change_to(SceneChanger.MainScenes.WORLD)

func _on_settings_button_pressed() -> void:
	settings_menu.show()
