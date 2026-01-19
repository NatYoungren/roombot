class_name Cleaner extends Node2D

@export var radius: float = 16.0



## Cleans filth from the given FilthLayer node within the specified radius and strength.
func clean_filth(filth_layer: Node2D) -> float:
	if not filth_layer is FilthLayer:
		push_error("clean_filth: Provided node is not a FilthLayer.")
		return 0.0
	
	var cleaned_amount: float = 0.0

	var filth_img: Image = filth_layer.image

	var filth_coords: Vector2 = filth_layer.to_local(global_position)
	
	# TODO: Make some Utility methods for:
	#		Clean circle
	#		Clean rect (considering rotation)
	#		Clean triangle ? (probably not important)
	
	for x in range(max(0, int(filth_coords.x - radius)), min(int(filth_coords.x + radius), filth_layer.img_size.x)):
		for y in range(max(0, int(filth_coords.y - radius)), min(int(filth_coords.y + radius), filth_layer.img_size.y)):
			var dist: float = filth_coords.distance_to(Vector2(x, y))
			
			if dist <= radius:
				cleaned_amount += filth_img.get_pixel(x, y).a
				filth_img.set_pixel(x, y, Color.TRANSPARENT)
				
	return cleaned_amount
