extends Node

var debug_enabled = true

func debug(text: String):
	if debug_enabled:
		print(text)
