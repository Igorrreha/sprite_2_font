extends HBoxContainer

class_name KeringItem


signal value_changed(char_a, char_b, kering)


var font :BitmapFont
var char_a :String
var char_b :String

onready var node_label = $Label
onready var node_spin_box = $SpinBox


func init(_font, _char_a, _char_b):
	font = _font
	char_a = _char_a
	char_b = _char_b
	
	return self


func _ready():
	node_label.set("custom_fonts/font", font)
	node_label.set_text(char_a + char_b)


func _on_SpinBox_value_changed(value):
	emit_signal("value_changed", char_a, char_b, value)
	node_label.set_text("")
	node_label.set_text(char_a + char_b)


func set_value(val):
	node_spin_box.set_value(val)


func set_font_scale(scale):
	pass
