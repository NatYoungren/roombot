## Cleans a circle of filth around the cleaner's position.
class_name CircleCleaner extends BaseCleaner

@export var radius: float = 16.0


## Cleans filth from the given FilthLayer node within the specified radius and strength.
func clean(filth_layer: Node2D) -> float:
	if not filth_layer is FilthLayer:
		push_error("clean_filth: Provided node is not a FilthLayer.")
		return 0.0
	
	var cleaned_amount: float = 0.0
	
	# TODO: Make some Utility methods for:
	#		Clean circle
	#		Clean rect (considering rotation)
	#		Clean triangle ? (probably not important)
	
	var filth_coords: Vector2 = filth_layer.to_local(global_position)

	for x in range(max(0, int(filth_coords.x - radius)), min(int(filth_coords.x + radius), filth_layer.img_size.x)):
		for y in range(max(0, int(filth_coords.y - radius)), min(int(filth_coords.y + radius), filth_layer.img_size.y)):
			var dist: float = filth_coords.distance_to(Vector2(x, y))
			
			if dist <= radius:
				cleaned_amount += filth_layer.clean_pixel(x, y)
				
	return cleaned_amount
