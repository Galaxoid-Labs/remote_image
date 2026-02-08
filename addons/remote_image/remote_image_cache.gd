# Autoload: remote_image_cache.gd
# RemoteImageCache
extends Node

var _cache: Dictionary[String, ImageTexture]

func get_image_for_url(url: String) -> ImageTexture:
	if _cache.has(url):
		return _cache[url]
	else:
		return null
		
func set_image_for_url(url: String, image: ImageTexture) -> void:
	_cache.set(url, image)
