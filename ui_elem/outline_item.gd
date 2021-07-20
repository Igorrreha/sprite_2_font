extends HBoxContainer

class_name OutlineStackItem


signal move_up
signal move_down
signal changed


var bitmask: BitMap = BitMap.new()

onready var node_color_picker = $ColorPickerButton
onready var node_enability = $Buttons/Enability
onready var color: Color = node_color_picker.color
onready var enable: bool = not node_enability.pressed


func _ready():
	bitmask.create(Vector2(8, 1))


func _on_Remove_pressed():
	queue_free()


func _on_ColorPickerButton_color_changed(_color):
	color = _color
	emit_signal("changed")


func _on_NW_toggled(button_pressed):
	bitmask.set_bit(Vector2(0, 0), button_pressed)
	emit_signal("changed")


func _on_N_toggled(button_pressed):
	bitmask.set_bit(Vector2(1, 0), button_pressed)
	emit_signal("changed")


func _on_NE_toggled(button_pressed):
	bitmask.set_bit(Vector2(2, 0), button_pressed)
	emit_signal("changed")


func _on_E_toggled(button_pressed):
	bitmask.set_bit(Vector2(3, 0), button_pressed)
	emit_signal("changed")


func _on_SE_toggled(button_pressed):
	bitmask.set_bit(Vector2(4, 0), button_pressed)
	emit_signal("changed")


func _on_S_toggled(button_pressed):
	bitmask.set_bit(Vector2(5, 0), button_pressed)
	emit_signal("changed")


func _on_SW_toggled(button_pressed):
	bitmask.set_bit(Vector2(6, 0), button_pressed)
	emit_signal("changed")


func _on_W_toggled(button_pressed):
	bitmask.set_bit(Vector2(7, 0), button_pressed)
	emit_signal("changed")


func _on_Up_pressed():
	emit_signal("move_up")


func _on_Down_pressed():
	emit_signal("move_down")


func _on_Visibility_toggled(button_pressed):
	enable = not button_pressed
	emit_signal("changed")
