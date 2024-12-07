extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/interfaces/instructions.tscn")

func _on_settings_pressed() -> void:
	var url = "https://sistemas.unmsm.edu.pe/site/index.php"
	OS.shell_open(url)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/interfaces/menu.tscn")
