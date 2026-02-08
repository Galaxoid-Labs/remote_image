@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("RemoteImageCache", "res://addons/remote_image/remote_image_cache.gd")
	
func _disable_plugin() -> void:
	remove_autoload_singleton("RemoteImageCache")
	
func _enter_tree() -> void:
	pass
	
func _exit_tree() -> void:
	pass
