extends LineEdit


signal click


func _on_LineEdit_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			emit_signal("click")

