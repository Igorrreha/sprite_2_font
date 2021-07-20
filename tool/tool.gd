tool

extends EditorScript


func _run():
	
	get_editor_interface().get_inspector()
	
#	var texture = load("res://img/theme-font-sheet__theme_rb.png")
#
#	var font = BitmapFont.new()
#	font.add_texture(texture)
#
#	var char_size = Vector2(11, 18)
#	var char_box_size = Vector2(20, 24)
#	var char_box_space = Vector2(5, 3)
#	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "
#
#	for i in range(0, texture.get_height(), char_box_size.y):
#		for j in range(0, texture.get_width(), char_box_size.x):
#
#			var char_idx = i / char_box_size.y * (texture.get_width() / char_box_size.x) + j / char_box_size.x
#
#			if char_idx >= chars.length():
#				break
#
#			var char_code = ord(chars[char_idx])
#			var char_rect = Rect2(Vector2(j, i) + char_box_space, char_size)
#			font.add_char(char_code, 0, char_rect)
#
#	font.add_kerning_pair(ord("l"), ord("l"), 6)
#
#	var node_label = get_scene().get_node("Label")
#	node_label.set("custom_fonts/font", font)
