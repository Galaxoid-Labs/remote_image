# Remote Image (Godot Plugin)

Remote Image is a lightweight Godot plugin that makes it easy to load images from a URL at runtime. It includes an in-memory cache so repeated requests for the same URL are served instantly without another download.

## Features

- Simple API for downloading images from URLs
- Runtime in-memory caching
- Supports: PNG, JPEG, SVG, WebP, BMP

## Installation

1. Copy the addons/remote_image folder into your project.
2. Enable the plugin in Project Settings → Plugins.

## Usage

- Enable the plugin after installing the asset.
- This will automatically add an autoload called RemoteImageCache and also give you access to the RemoteImageRequest node.

```gdscript
const url = "https://godotengine.org/assets/press/logo_large_color_light.png"

var req = RemoteImageRequest.new(url, true)
req.received.connect(_on_image_received)
req.failed.connect(_on_image_failed)
add_child(req)
req.download()

func _on_image_received(image: ImageTexture, url: String, from_cache: bool) -> void:
	if image:
		print("Received image from: ", url)
		print("From cache: ", from_cache)
		$MarginContainer/TextureRect.texture = image
	else:
		print("At this point, this should never happen...")
	
func _on_image_failed(url: String, error: String) -> void:
	print("Image load failed for: ", url, error)
```

### Signals

- `received(image: ImageTexture, url: String, from_cache: bool)` – emitted when the image is downloaded and decoded
- `failed(url: String, error: String)` – emitted when the download or decode fails

## Notes

- Cache is in-memory and lasts for the lifetime of the running game.
- If the same URL is requested again, the cached image is returned immediately.

## TODO
- Maybe add persistant caching?

## Acknowledgments
- https://github.com/Skyvastern/image-download-tutorial

## License

See [LICENSE](LICENSE).
