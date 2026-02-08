extends CanvasLayer

func _ready() -> void:
	var req = RemoteImageRequest.new("https://godotengine.org/assets/press/logo_large_color_light.png")
	req.received.connect(_on_image_received)
	req.failed.connect(_on_image_failed)
	add_child(req)
	req.download()
	
func _on_image_received(image: ImageTexture, url: String) -> void:
	if image != null:
		print("Received image from: ", url)
		$TextureRect.texture = image
		$TextureRect.set_size(Vector2(500, 500))
	
func _on_image_failed(url: String, error: String) -> void:
	print("Image load failed for: ", url, error)
