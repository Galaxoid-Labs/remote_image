extends Control

func _ready() -> void:
	# Create new RemoteImageRequest
	# Wire up the signals
	# add to the scene
	# Initiate the download
	# The remote request node will automatically remove itself from the tree after success or failure if you pass true
	# as second argument
	# If you want to reuse the same request you can pass false and then use .set_url to reuse again
	# although, probably easiest to just create new requests.
	
	const url = "https://godotengine.org/assets/press/logo_large_color_light.png"

	var req = RemoteImageRequest.new(url, true)
	req.received.connect(_on_image_received)
	req.failed.connect(_on_image_failed)
	add_child(req)
	req.download()
	
	await get_tree().create_timer(3.0).timeout
	
	# Images are cached at runtime.
	# You can check from images in the RemoteImageCache like this
	var cached_image = RemoteImageCache.get_image_for_url(url)
	if cached_image:
		print("Image is available from cache!")
	
	# But probably better, just call them as you would normally. It will simply just grab
	# the image from the cache and not make a request. You will simply get the image via the signal like normal,
	# but no network request is made. This way, you don't have to have 2 code paths for handling images.
	var req2 = RemoteImageRequest.new(url, true)
	req2.received.connect(_on_image_received)
	req2.failed.connect(_on_image_failed)
	add_child(req2)
	req2.download()
	
	
func _on_image_received(image: ImageTexture, url: String, from_cache: bool) -> void:
	if image:
		print("Received image from: ", url)
		print("From cache: ", from_cache)
		$MarginContainer/TextureRect.texture = image
	else:
		print("At this point, this should never happen...")
	
func _on_image_failed(url: String, error: String) -> void:
	print("Image load failed for: ", url, error)
