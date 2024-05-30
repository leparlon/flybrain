@tool
extends EditorPlugin

func _enter_tree():
	# Register the custom node
	add_custom_type("FlyNode", "Node2D", preload("drosophila.gd"), preload("icon.png"))

func _exit_tree():
	# Unregister the custom node
	remove_custom_type("FlyNode")
