extends HTTPRequest
class_name RemoteImageRequest
## This class allows you to download and cache remote images from a url
## Usage:
## [codeblock]
## func _ready():
##    const url = "https://godotengine.org/assets/press/logo_large_color_light.png"
##
##    # You can pass false after the url if you don't want the RemoteImageRequest to be
##    # removed from the scene automatically. This would allow you to reuse the request
##    var req = RemoteImageRequest.new(url, true)
##    req.received.connect(_on_image_received)
##    req.failed.connect(_on_image_failed)
##    add_child(req)
##    req.download()
##
##
##func _on_image_received(image: ImageTexture, url: String, from_cache: bool) -> void:
##    if image:
##        print("Received image from: ", url)
##        print("From cache: ", from_cache)
##        $MarginContainer/TextureRect.texture = image
##    else:
##        print("At this point, this should never happen...")
##
##func _on_image_failed(url: String, error: String) -> void:
##    print("Image load failed for: ", url, error)
## [/codeblock]

## (image: [ImageTexture], url: [String], from_cache: [bool])
## This signal is called on successful download or return from cache
signal received

## (url: [String], error: [String])
## This signal is called on error
signal failed

var _image_load_method: String
const _valid_types: Dictionary = {
	"image/png": "load_png_from_buffer",
	"image/jpeg": "load_jpg_from_buffer",
	"image/svg+xml": "load_svg_from_buffer",
	"image/webp": "load_webp_from_buffer",
	"image/bmp": "load_bmp_from_buffer"
}

var _url: String
var _remove_when_done: bool

## Set a new url for the request to use
func set_url(url: String) -> void:
	_url = url

## Initiate the download of the image after setting url
func download() -> void:
	var has_prefix = _url.begins_with("https://") || _url.begins_with("http://")
	
	if not has_prefix:
		failed.emit(_url, "No proper url")
		if _remove_when_done:
			queue_free()
		return
		
	var cached_image = RemoteImageCache.get_image_for_url(_url)
	if cached_image != null:
		received.emit(cached_image, _url, true)
		if _remove_when_done:
			queue_free()
		return
		
	var error: Error = request(_url)
	if error != OK:
		failed.emit(_url, error_string(error))
		if _remove_when_done:
			queue_free()
		return

func _init(url: String, remove_when_done: bool = true) -> void:
	_url = url
	_remove_when_done = remove_when_done

func _ready() -> void:
	request_completed.connect(_on_request_completed)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		failed.emit(_url, error_string(result))
		if _remove_when_done:
			queue_free()
		return
		
	var content_type: String = ""
	
	for val in headers:
		if val.begins_with("Content-Type: "):
			content_type = val.split("Content-Type: ")[1]
			break
			
	_image_load_method = _valid_types.get(content_type, "")
	var image: Image = Image.new()
	var error: Error = FAILED
	
	if _image_load_method != "":
		error = image.call(_image_load_method, body)
		if error != OK:
			failed.emit(_url, error_string(error))
			if _remove_when_done:
				queue_free()
			return
	else:
		failed.emit(_url, "unhandled image type")
		if _remove_when_done:
			queue_free()
		return
			
	var image_texture = ImageTexture.create_from_image(image)
	RemoteImageCache.set_image_for_url(_url, image_texture)
	received.emit(image_texture, _url, false)
	if _remove_when_done:
		queue_free()
