class_name FilthLayer extends Node2D

# TODO:
# fix_alpha_edges could be useful to clean up edges after drawing/erasing.

@onready var sprite: Sprite2D = $sprite

@export var img_size: Vector2i = Vector2i(256, 256)

var image: Image

var debug_color: Color = Color.GREEN

var refresh_needed: bool = false

# # #
# Initialization

func _init_image(size: Vector2i = img_size) -> Image:
	var img: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8) # TODO: Try simpler formats (1/2 channels)
	return img

func _ready() -> void:
	image = _init_image(img_size)
	var tex: ImageTexture = ImageTexture.create_from_image(image)
	sprite.texture = tex

	# Store self-reference in global state.
	# TODO: This only supports one filth layer at a time.
	State.filth_layer = self

# # #
# Public methods

func clean_pixel(x: int, y: int) -> float:
	# NOTE: No bounds checking.
	var alpha: float = image.get_pixel(x, y).a
	image.set_pixel(x, y, Color.TRANSPARENT)
	#refresh_needed = true
	return alpha

func color_pixel(x: int, y: int, clr: Color) -> void:
	# NOTE: No bounds checking.
	image.set_pixel(x, y, clr)
	#refresh_needed = true


func blend_pixel(x: int, y: int, clr: Color, weight: float = 0.5) -> void:
	# NOTE: No bounds checking.
	var dst_clr: Color = image.get_pixel(x, y)
	var blended_clr: Color = dst_clr.lerp(clr, weight)
	color_pixel(x, y, blended_clr)
	#refresh_needed = true

## Draw src_img onto filth_layer, with top_left corner at the given pos.
## 	alpha_mod: Scales src_img opacity.
## 	skip_transparent: Skips over transparent src_img pixels (to avoid removing filth).
func apply_image_at(x: int, y: int, src_img: Image, alpha_mod: float = 1.0, skip_transparent: bool = true) -> void:
	# TODO: Blend argument?
	var src_size: Vector2i = src_img.get_size()
	
	# NOTE: These are bounds for the portion of src_image that overlap filth_layer.
	var x_range: Vector2i = Vector2i(max(-x, 0), min(src_size.x, img_size.x-x))
	var y_range: Vector2i = Vector2i(max(-y, 0), min(src_size.y, img_size.y-y))
	
	# Loop over src_image pixels, pasting onto filth_layer with pos offset.
	# 	Would be good to find a way to optimize w/ get_region, or by editing image data directly.
	#	Cannot see a built-in way to plop an Image onto another, but thats not too surprising.
	for src_x in range(x_range.x, x_range.y):
		for src_y in range(y_range.x, y_range.y):
			var src_clr: Color = src_img.get_pixel(src_x, src_y)
			
			if skip_transparent and src_clr.a == 0.0: continue
			src_clr.a *= alpha_mod
			
			# TODO: Blend pixels?
			color_pixel(x + src_x, y + src_y, src_clr)


func apply_image_from_file(x: int, y: int, file_path: String, alpha_mod: float = 1.0) -> void:
	var src_img: Image = Image.new()
	var _err: Error = src_img.load(file_path) # TODO: Causes a warning. Preload images.
	#print("Loaded image from file ", file_path, ": ", _err)
	
	apply_image_at(x, y, src_img, alpha_mod)

# # #
# Debug methods

func debug_fill_image(clr: Color = debug_color) -> void:
	image.fill(clr)
	#refresh_needed = true

func random_junk(x: int = randi() % img_size.x, y: int = randi() % img_size.y, alpha: float = 1.0) -> void:
	var n_junk_imgs: int = 2
	apply_image_from_file(x, y, "res://assets/filth/junk" + str((randi() % n_junk_imgs) + 1) + ".png", alpha)


# # #
# Update methods
func _process(_delta: float) -> void:
	# DEBUG: Adds a random green pixel each frame
	color_pixel(randi() % img_size.x, randi() % img_size.y, debug_color)
	
	# This is ok for now.
	# TODO: Only recreate texture if changes are made?
	#		Could we modify the existing texture somehow?
	sprite.texture = ImageTexture.create_from_image(image)
	#if refresh_needed: 
		#sprite.texture = ImageTexture.create_from_image(image)
		#refresh_needed = false
		
