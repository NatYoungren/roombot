class_name FilthLayer extends Node2D

# TODO:
# fix_alpha_edges could be useful to clean up edges after drawing/erasing.



@onready var sprite: Sprite2D = $sprite

@export var img_size: Vector2i = Vector2i(256, 256)

var image: Image

var debug_color: Color = Color.GREEN


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

func clean_pixel(pos: Vector2i) -> float:
	# NOTE: No bounds checking.
	var alpha: float = image.get_pixel(pos.x, pos.y).a
	image.set_pixel(pos.x, pos.y, Color.TRANSPARENT)
	return alpha

func color_pixel(pos: Vector2i, clr: Color) -> void:
	# NOTE: No bounds checking.
	image.set_pixel(pos.x, pos.y, clr)

# TODO: Paste image method


# # #
# Debug methods

func debug_fill_image(clr: Color = debug_color) -> void:
	image.fill(clr)


func _process(_delta: float) -> void:
	# DEBUG: Adds a random green pixel each frame
	color_pixel(Vector2i(randi() % img_size.x, randi() % img_size.y), debug_color)

	# This is ok for now.
	# TODO: Only recreate texture if changes are made?
	#		Could we modify the existing texture somehow?
	sprite.texture = ImageTexture.create_from_image(image)
