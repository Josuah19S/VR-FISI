extends Control

func _on_xplore_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/info.tscn")

func _on_settings_pressed() -> void:
	var url = "https://sistemas.unmsm.edu.pe/site/index.php"
	OS.shell_open(url)

func _on_quit_pressed() -> void:
	get_tree().quit()
