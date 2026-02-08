##### Example of how to use
#extends CanvasLayer
#
#	func _ready() -> void:
#		var req = RemoteImageRequest.new("https://godotengine.org/assets/press/logo_large_color_light.png")
#		req.received.connect(_on_image_received)
#		req.failed.connect(_on_image_failed)
#		add_child(req)
#		req.download()
#
#	func _on_image_received(image: ImageTexture, url: String) -> void:
#		if image != null:
#			print("Received image from: ", url)
#			$TextureRect.texture = image
#
#	func _on_image_failed(url: String, error: String) -> void:
#		print("Image load failed for: ", url, error)

extends HTTPRequest
class_name RemoteImageRequest

signal received
signal failed

var image_load_method: String
const valid_types: Dictionary = {
	"image/png": "load_png_from_buffer",
	"image/jpeg": "load_jpg_from_buffer",
	"image/svg+xml": "load_svg_from_buffer",
	"image/webp": "load_webp_from_buffer",
	"image/bmp": "load_bmp_from_buffer"
}

var url: String

func download() -> void:
	var has_prefix = url.begins_with("https://") || url.begins_with("http://")
	
	if not has_prefix:
		failed.emit(url, "No proper url")
		return
		
	var cached_image = RemoteImageCache.get_image_for_url(url)
	if cached_image != null:
		received.emit(cached_image, url)
		return
		
	var error: Error = request(url)
	if error != OK:
		failed.emit(url, error_string(error))
		return
		
func _init(url: String) -> void:
	self.url = url
	
func _ready() -> void:
	request_completed.connect(_on_request_completed)
	
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		failed.emit(url, error_string(result))
		queue_free()
		return
		
	var content_type: String = ""
	
	for val in headers:
		if val.begins_with("Content-Type: "):
			content_type = val.split("Content-Type: ")[1]
			break
			
	image_load_method = valid_types.get(content_type, "")
	var image: Image = Image.new()
	var error: Error = FAILED
	
	if image_load_method != "":
		error = image.call(image_load_method, body)
		if error != OK:
			failed.emit(url, error_string(error))
			queue_free()
			return
	else:
		failed.emit(url, "unhandled image type")
		queue_free()
		return
			
	var image_texture = ImageTexture.create_from_image(image)
	RemoteImageCache.set_image_for_url(url, image_texture)
	received.emit(image_texture, url)
	queue_free()
