## Cleans a rectangle of filth around the cleaner's position.
class_name RectCleaner extends BaseCleaner

@export var width: float = 16.0
@export var height: float = 16.0

@export var can_rotate: bool = false # TODO: Implement?

func clean(filth_layer: Node2D) -> float:
	if not filth_layer is FilthLayer:
		push_error("clean_filth: Provided node is not a FilthLayer.")
		return 0.0

	# TODO: Implement alternate function which considers rotation.

	var cleaned_amount: float = 0.0

	var filth_coords: Vector2 = filth_layer.to_local(global_position)

	var start_x: int = max(0, int(filth_coords.x - width / 2))
	var end_x: int = min(int(filth_coords.x + width / 2), filth_layer.img_size.x)
	var start_y: int = max(0, int(filth_coords.y - height / 2))
	var end_y: int = min(int(filth_coords.y + height / 2), filth_layer.img_size.y)

	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			cleaned_amount += filth_layer.clean_pixel(x, y)
				
	return cleaned_amount
