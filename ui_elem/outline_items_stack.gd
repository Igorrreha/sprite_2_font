extends ScrollContainer


signal outline_changed


onready var tscn_item = preload("res://ui_elem/outline_item.tscn")
onready var node_items = $VBoxContainer/Items


func _ready():
	for child in node_items.get_children():
		child.connect("move_up", self, "move_child_up", [child])
		child.connect("move_down", self, "move_child_down", [child])
		child.connect("changed", self, "emit_signal", ["outline_changed"])


# add item
func _on_Button_pressed():
	var item = tscn_item.instance()
	node_items.add_child(item)
	
	item.connect("move_up", self, "move_child_up", [item])
	item.connect("move_down", self, "move_child_down", [item])
	item.connect("changed", self, "emit_signal", ["outline_changed"])


func move_child_up(child):
	var idx = child.get_index()
	if idx > 0:
		node_items.move_child(child, idx - 1)
	
	emit_signal("outline_changed")


func move_child_down(child):
	var idx = child.get_index()
	if idx < node_items.get_child_count() - 1:
		node_items.move_child(child, idx + 1)
	
	emit_signal("outline_changed")


func apply_outline_to_image(img: Image) -> Image: 
	
	img.lock()
	
	# for each child
	for child in node_items.get_children():
		
		# ignore disabled items
		if not child.enable:
			continue
		
		
		var buffered_img: Image = Image.new()
		buffered_img.copy_from(img)
		
		buffered_img.lock()
		
		# apply shadow
		for i in buffered_img.get_width():
			for j in buffered_img.get_height():
				
				# skip empty pixels
				if buffered_img.get_pixel(i, j).a == 0.0:
					continue
				
				# draw outline
				## NW
				if (i - 1 >= 0 
				and j - 1 >= 0
				and child.bitmask.get_bit(Vector2(0, 0)) 
				and buffered_img.get_pixel(i - 1, j - 1).a == 0.0):
					img.set_pixel(i - 1, j - 1, child.color)
				
				## N
				if (j - 1 >= 0
				and child.bitmask.get_bit(Vector2(1, 0))
				and buffered_img.get_pixel(i, j - 1).a == 0.0):
					img.set_pixel(i, j - 1, child.color)
				
				## NE
				if (i + 1 < buffered_img.get_width() - 1
				and j - 1 >= 0
				and child.bitmask.get_bit(Vector2(2, 0)) 
				and buffered_img.get_pixel(i + 1, j - 1).a == 0.0):
					img.set_pixel(i + 1, j - 1, child.color)
				
				## E
				if (i + 1 < buffered_img.get_width() - 1
				and child.bitmask.get_bit(Vector2(3, 0)) 
				and buffered_img.get_pixel(i + 1, j).a == 0.0):
					img.set_pixel(i + 1, j, child.color)
				
				## SE
				if (i + 1 < buffered_img.get_width() - 1
				and j + 1 < buffered_img.get_height() - 1
				and child.bitmask.get_bit(Vector2(4, 0)) 
				and buffered_img.get_pixel(i + 1, j + 1).a == 0.0):
					img.set_pixel(i + 1, j + 1, child.color)
				
				## S
				if (j + 1 < buffered_img.get_height() - 1
				and child.bitmask.get_bit(Vector2(5, 0)) 
				and buffered_img.get_pixel(i, j + 1).a == 0.0):
					img.set_pixel(i, j + 1, child.color)
				
				## SW
				if (i - 1 >= 0
				and j + 1 < buffered_img.get_height() - 1
				and child.bitmask.get_bit(Vector2(6, 0)) 
				and buffered_img.get_pixel(i - 1, j + 1).a == 0.0):
					img.set_pixel(i - 1, j + 1, child.color)
				
				## W
				if (i - 1 >= 0
				and child.bitmask.get_bit(Vector2(7, 0)) 
				and buffered_img.get_pixel(i - 1, j).a == 0.0):
					img.set_pixel(i - 1, j, child.color)
	
	return img
