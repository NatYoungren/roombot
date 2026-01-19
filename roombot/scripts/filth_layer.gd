class_name FilthLayer extends Node2D

# TODO:
# fix_alpha_edges could be useful to clean up edges after drawing/erasing.



@onready var sprite: Sprite2D = $sprite

@export var img_size: Vector2i = Vector2i(256, 256)

var image: Image

func _init_image(size: Vector2i = img_size) -> Image:
	var img: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8) # TODO: Try simpler formats (1/2 channels)
	return img

# func _create_blank_texture(_size: Vector2i = img_size) -> Texture2D:
# 	return Texture2D.new()


func _ready() -> void:
	image = _init_image(img_size)
	var tex: ImageTexture = ImageTexture.create_from_image(image)
	sprite.texture = tex

func _process(_delta: float) -> void:
	# DEBUG: Adds a random green pixel each frame
	image.set_pixel(randi() % img_size.x, randi() % img_size.y, Color.GREEN)
	sprite.texture = ImageTexture.create_from_image(image)
