extends VBoxContainer


signal text_changed()
signal bg_color_changed(color)
signal scale_changed(scale)


onready var node_text_edit = $Control/TextEdit
onready var node_color_picker = $HBoxContainer/ColorPickerButton
onready var node_spin_box = $HBoxContainer/SpinBox
onready var node_scale_spin_box = $HBoxContainer/SpinBox


func _ready():
	set_bg_color(node_text_edit.get("custom_styles/normal").bg_color)
	node_text_edit.connect("text_changed", self, "emit_signal", ["text_changed"])


func get_text():
	return node_text_edit.text


func set_text(text):
	node_text_edit.set_text(text)


func set_font(font):
	node_text_edit.set("custom_fonts/font", font)
	node_text_edit.set_text(node_text_edit.text) # for font updating


func set_bg_color(color):
	node_color_picker.color = color


func set_text_scale(value):
	node_scale_spin_box.set_value(value)


func _on_ColorPickerButton_color_changed(color):
	node_text_edit.get("custom_styles/normal").bg_color = color
	emit_signal("bg_color_changed", color)


func _on_SpinBox_value_changed(value):
	node_text_edit.anchor_right = 1.0 / value
	node_text_edit.anchor_bottom = 1.0 / value
	node_text_edit.rect_scale = Vector2(1, 1) * value
	emit_signal("scale_changed", value)
