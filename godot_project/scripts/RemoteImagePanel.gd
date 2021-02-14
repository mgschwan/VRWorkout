extends Spatial

export(String) var http_download_url = ""
var image_download_inprogress = false
var image_texture

func get_cache_filename(fname):
	return "user://download_cache/%s"%fname

func get_resource_filename(fname):
	return "res://download_cache/%s"%fname

func get_filename_from_url(url):
	var fname = url.get_file()
	if fname and not fname.ends_with(".png"):
		fname = "%s.png"%fname
	return fname
	
func save_url_image(image, url):
	var d = Directory.new()
	d.open("user://")
	if not d.dir_exists("download_cache"):
		print ("Create cache")
		d.make_dir("download_cache")
	else:
		print ("Cache exists")
	
	var fname = get_filename_from_url(url)
	print ("Save filename: %s"%fname)
	if fname:
		image.save_png(get_cache_filename(fname))

func _image_http_download_finished(result, response_code, headers, body):
	var image = Image.new()
	var error = ERR_CANT_OPEN
	if http_download_url.ends_with(".png"):
		error = image.load_png_from_buffer(body)
	elif http_download_url.ends_with(".jpg"):
		error = image.load_jpg_from_buffer(body)
		
	if error != OK:
		push_error("Couldn't load the image.")
	else:
		save_url_image(image, http_download_url)
	
	image_download_inprogress = false

func get_image_from_url(url):
	if not image_download_inprogress:
		image_download_inprogress = true
		var req = $HTTPRequest

		var error = req.request(url)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
			image_download_inprogress = false
			
		while image_download_inprogress:
			yield(get_tree().create_timer(0.1),"timeout")

func get_image_texture():
	var retVal = ImageTexture.new()
	var filename
	if http_download_url.find("res://") == 0:
		filename = http_download_url
	else:
		filename = get_cache_filename(get_filename_from_url(http_download_url))

	var f = File.new()
	
	if not f.file_exists(filename):
		print ("Cache file does not exist, downloading")
		var co = get_image_from_url(http_download_url)
		if co is GDScriptFunctionState and co.is_valid():
			yield(co, "completed")
	
	var img = Image.new()
	img.load(filename)
	var t = ImageTexture.new()
	retVal.create_from_image(img)
	image_texture = retVal

func _ready():
	print ("Get image texture")
	if http_download_url:
		var co = get_image_texture()
		if co is GDScriptFunctionState and co.is_valid():
			yield(co,"completed")
		print ("Set material")
		var mat = get_node("MeshInstance").get_surface_material(0)
		mat.albedo_texture = image_texture
	
	
		
		

