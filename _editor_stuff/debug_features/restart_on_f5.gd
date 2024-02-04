extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_filedialog_refresh"):
		get_tree().reload_current_scene()
