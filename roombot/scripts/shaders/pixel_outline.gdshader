shader_type canvas_item;

// TODO: Use 'region_enabled' on sprites TO PREVENT SPRITESHEET SHADER ARTIFACTS.

// SOURCE: https://www.youtube.com/watch?v=QYGeXW4yayU

// Multiplier for outline alpha.
uniform float opacity = 1.0f;

//// TODO: Could just adjust outline color alpha channel...
//uniform vec4 color_mult: source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Color of outline.
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// If true, outline corner pixels.
uniform bool corner_pixel = false;

// Stores modulated color at each vertex.
varying vec4 mod_color;


// todo: alpha threshold (only put outlines around pixels w/ alpha above threshold)

void vertex() {
	mod_color = COLOR;
}

void fragment() {
	// TOOD: Use mod color rather than base? Or multiply by mod color?
	vec4 base = texture(TEXTURE, UV);
	
	if (base.a > 0.0){
		COLOR = mod_color;
	} else {
		vec2 image_pixel_size = TEXTURE_PIXEL_SIZE;
		bool valid_side = 
			texture(TEXTURE, UV + vec2(-image_pixel_size.x, 0)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(image_pixel_size.x, 0)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(0, -image_pixel_size.y)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(0, image_pixel_size.y)).a > 0.0;
	
		bool valid_corner =
			texture(TEXTURE, UV + vec2(-image_pixel_size.x, -image_pixel_size.y)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(image_pixel_size.x, -image_pixel_size.y)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(-image_pixel_size.x, image_pixel_size.y)).a > 0.0 ||
			texture(TEXTURE, UV + vec2(image_pixel_size.x, image_pixel_size.y)).a > 0.0;
		
		if (valid_side || (corner_pixel && valid_corner)) {
			COLOR = outline_color;
			COLOR.a *= alpha_mult;
		}
	}
}
