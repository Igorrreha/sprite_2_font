shader_type canvas_item;


uniform float scale = 3.0;


void vertex() {
	VERTEX = VERTEX * scale;
}
