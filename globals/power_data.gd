extends Node

enum Powers {
	None,
	Testing,
}

var power_classes: Array = [
	preload("res://classes/power_up.gd"),
	preload("res://classes/power_ups/testing.gd")
]
