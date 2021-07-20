extends Node


signal font_changed(font)
signal path_to_font_texture_changed(path)


export var path_to_font_texture: String
export var charset: String
export var char_size: Vector2
export var charbox_size: Vector2
export var charbox_margin: Vector2

var output_font: BitmapFont
var output_font_scale: Vector2
var output_font_charset: String
var output_char_size: Vector2
var output_charbox_size: Vector2
var output_charbox_margin: Vector2

var kering_filter_char_a := ""
var kering_filter_char_b := ""

var link_to_test_spritesheet_file = "https://youlikeit.itch.io/sprite2font"
var link_to_yli = "https://youlikeit.itch.io"

var default_font_texture_img: Image = preload("res://img/font_sheet.png")
var use_default_font_texture = true

onready var tscn_kering_pairs_grid = preload("res://ui_elem/kering_pairs_grid.tscn")
onready var tscn_kering_item = preload("res://ui_elem/kering_item.tscn")

onready var node_font_texture = $UI/VSplitContainer/TabContainer/Main/Options/HBoxContainer/LineEditTexture
onready var node_use_default_texture_button = $UI/VSplitContainer/TabContainer/Main/Options/HBoxContainer/Button
onready var node_charset = $UI/VSplitContainer/TabContainer/Main/Options/LineEditCharset
onready var node_char_size_x = $UI/VSplitContainer/TabContainer/Main/Options/CharSizeHBox/X
onready var node_char_size_y = $UI/VSplitContainer/TabContainer/Main/Options/CharSizeHBox/Y
onready var node_charbox_size_x = $UI/VSplitContainer/TabContainer/Main/Options/CharBoxSizeHBox/X
onready var node_charbox_size_y = $UI/VSplitContainer/TabContainer/Main/Options/CharBoxSizeHBox/Y
onready var node_charbox_margin_x = $UI/VSplitContainer/TabContainer/Main/Options/CharBoxMarginHBox/X
onready var node_charbox_margin_y = $UI/VSplitContainer/TabContainer/Main/Options/CharBoxMarginHBox/Y
onready var node_create_font_button = $UI/VSplitContainer/TabContainer/Main/CreateFont
onready var node_main_text_edit = $UI/VSplitContainer/TabContainer/Main/Output/TestTextEdit

onready var node_outline_stack = $UI/VSplitContainer/TabContainer/Outline/OutlineStack
onready var node_outline_text_edit = $UI/VSplitContainer/TabContainer/Outline/TestTextEdit

onready var node_kering_filter_char_a = $UI/VSplitContainer/TabContainer/Kering/Options/Filter/CharA
onready var node_kering_filter_char_b = $UI/VSplitContainer/TabContainer/Kering/Options/Filter/CharB
onready var node_kering_pairs_grid = $UI/VSplitContainer/TabContainer/Kering/Items/GridContainer
onready var node_kering_pairs_grid_spin_box_columns = $UI/VSplitContainer/TabContainer/Kering/Options/SpinBoxColumns
onready var node_kering_apply_to_filtered_button = $UI/VSplitContainer/TabContainer/Kering/Options/ButtonApplyToSelected
onready var node_kering_apply_to_filtered = $UI/VSplitContainer/TabContainer/Kering/Options/SpinBoxApplyToSelected
onready var node_autokering_button = $UI/VSplitContainer/TabContainer/Kering/Options/ButtonAutokering
onready var node_autokering = $UI/VSplitContainer/TabContainer/Kering/Options/SpinBoxAutokering

onready var node_test_spritesheet_link_button = $UI/VSplitContainer/Panel/VBoxContainer/HBoxContainer/LinkButton
onready var node_powered_by_button = $Sprite/HBoxContainer/ButtonPoweredBy

onready var node_export_button = $UI/VSplitContainer/TabContainer/Export/ButtonExport

onready var node_file_dialog_open = $UI/FileDialogOpen
onready var node_file_dialog_save = $UI/FileDialogSave


func _ready():
	
	if OS.get_name() == "HTML5":
		node_font_texture.placeholder_text = "Unavailable in web version, use the button on the right ->"
#		node_export_button.connect("pressed", self, "save_file_from_web")
		node_export_button.disabled = true
	else:
		# open file choose popup
		node_font_texture.connect("click", node_file_dialog_open, "popup")
		node_export_button.connect("pressed", node_file_dialog_save, "popup")
	
	# connect buttons
	node_use_default_texture_button.connect("pressed", self, "load_default_font_texture")
	node_create_font_button.connect("pressed", self, "create_font")
	
	# refresh texture image file path in line edit
	connect("path_to_font_texture_changed", node_font_texture, "set_text")
	
	# change font in child
	connect("font_changed", node_main_text_edit, "set_font")
	connect("font_changed", node_outline_text_edit, "set_font")
	
	# connect outputs
	node_main_text_edit.connect("text_changed", self, "output_test_text_changed", [node_main_text_edit])
	node_outline_text_edit.connect("text_changed", self, "output_test_text_changed", [node_outline_text_edit])
	node_main_text_edit.connect("bg_color_changed", self, "output_test_bg_color_changed", [node_main_text_edit])
	node_outline_text_edit.connect("bg_color_changed", self, "output_test_bg_color_changed", [node_outline_text_edit])
	node_main_text_edit.connect("scale_changed", self, "output_test_scale_changed", [node_main_text_edit])
	node_outline_text_edit.connect("scale_changed", self, "output_test_scale_changed", [node_outline_text_edit])
	
	
	# apply outline to font image
	node_outline_stack.connect("outline_changed", self, "update_font_texture")
	
	# apply kering to filtered items
	node_kering_apply_to_filtered_button.connect("pressed", self, "apply_kering_to_filtered_items")
	
	# change kering grid columns count
	node_kering_pairs_grid_spin_box_columns.connect("value_changed", node_kering_pairs_grid, "set_columns")
	
	# calculate kering by empty space between chars
	node_autokering_button.connect("pressed", self, "autocalculate_kering")
	
	# open links
	node_test_spritesheet_link_button.connect("pressed", self, "open_link_to_test_spritesheet")
	node_powered_by_button.connect("pressed", self, "open_link_to_yli")
	
	# set vars from ui els
	node_charset.connect("text_changed", self, "set_charset")
	node_char_size_x.connect("value_changed", self, "set_char_size_x")
	node_char_size_y.connect("value_changed", self, "set_char_size_y")
	node_charbox_size_x.connect("value_changed", self, "set_charbox_size_x")
	node_charbox_size_y.connect("value_changed", self, "set_charbox_size_y")
	node_charbox_margin_x.connect("value_changed", self, "set_charbox_margin_x")
	node_charbox_margin_y.connect("value_changed", self, "set_charbox_margin_y")
	node_kering_filter_char_a.connect("text_changed", self, "set_kering_filter_char_a")
	node_kering_filter_char_b.connect("text_changed", self, "set_kering_filter_char_b")
	
	# set default values
	node_charset.set_text(charset)
	node_char_size_x.set_value(char_size.x)
	node_char_size_y.set_value(char_size.y)
	node_charbox_size_x.set_value(charbox_size.x)
	node_charbox_size_y.set_value(charbox_size.y)
	node_charbox_margin_x.set_value(charbox_margin.x)
	node_charbox_margin_y.set_value(charbox_margin.y)
	node_main_text_edit.set_text(charset)
	node_outline_text_edit.set_text(charset)
	node_kering_filter_char_a.set_text(kering_filter_char_a)
	node_kering_filter_char_b.set_text(kering_filter_char_b)
	
	# make filedrop enabled
	get_tree().connect("files_dropped", self, "files_dropped")


# setters
func set_charset(val):
	charset = val

func set_char_size_x(val):
	char_size.x = val

func set_char_size_y(val):
	char_size.y = val

func set_charbox_size_x(val):
	charbox_size.x = val

func set_charbox_size_y(val):
	charbox_size.y = val

func set_charbox_margin_x(val):
	charbox_margin.x = val

func set_charbox_margin_y(val):
	charbox_margin.y = val

func set_kering_filter_char_a(val):
	kering_filter_char_a = val
	apply_kering_filter()

func set_kering_filter_char_b(val):
	kering_filter_char_b = val
	apply_kering_filter()


func output_test_text_changed(node):
	var text = node.get_text()
	
	if not node == node_main_text_edit:
		node_main_text_edit.set_text(text)
	
	if not node == node_outline_text_edit:
		node_outline_text_edit.set_text(text)

func output_test_bg_color_changed(color, node):
	if not node == node_main_text_edit:
		node_main_text_edit.set_bg_color(color)
	
	if not node == node_outline_text_edit:
		node_outline_text_edit.set_bg_color(color)

func output_test_scale_changed(value, node):
	if not node == node_main_text_edit:
		node_main_text_edit.set_text_scale(value)
	
	if not node == node_outline_text_edit:
		node_outline_text_edit.set_text_scale(value)


# create bitmap font instance by spritesheet texture and push it into output_font
func create_font():
	
	# get texture
	var texture = get_font_texture()
	
	# create btf instance
	var font = BitmapFont.new()
	font.height = char_size.y
	font.add_texture(texture)
	
	
	# load characters from image
	for i in range(0, texture.get_height(), charbox_size.y):
		for j in range(0, texture.get_width(), charbox_size.x):
			
			var char_idx = i / (charbox_size.y) * (texture.get_width() / charbox_size.x) + j / charbox_size.x
			
			if char_idx >= charset.length():
				break
			
			var char_code = ord(charset[char_idx])
			var char_rect = Rect2(Vector2(j, i) + charbox_margin, char_size)
			font.add_char(char_code, 0, char_rect)
	
	
	# push to output
	output_font = font
	output_font_charset = charset
	output_char_size = char_size
	output_charbox_size = charbox_size
	output_charbox_margin = charbox_margin
	emit_signal("font_changed", output_font)
	
	
	# generate kering pairs
	generate_kering_grid_items()


func update_font_texture():
	if output_font == null:
		return
	
	output_font.textures[0] = get_font_texture()
	
	emit_signal("font_changed", output_font)


func get_font_texture():
	
	var external_texture_img: = Image.new()
	
	if use_default_font_texture:
		external_texture_img.copy_from(default_font_texture_img)
	else:
		external_texture_img.load(path_to_font_texture)
	
	var texture_img: Image = node_outline_stack.apply_outline_to_image(external_texture_img)
	
	var texture = ImageTexture.new()
	texture.create_from_image(texture_img, 0)
	
	return texture


func generate_kering_grid_items():
	# remove all items
	var new_grid = tscn_kering_pairs_grid.instance()
	var kering_grid_parent = node_kering_pairs_grid.get_parent()
	node_kering_pairs_grid.free()
	kering_grid_parent.add_child(new_grid)
	node_kering_pairs_grid = new_grid
	
	
	for i in range(0, charset.length()):
		for j in range(0, charset.length()):
			var kering_item = tscn_kering_item.instance().init(output_font, charset[i], charset[j])
			node_kering_pairs_grid.add_child(kering_item)
			
			kering_item.connect("value_changed", self, "set_kering")
	
	apply_kering_filter()


func set_kering(char_a, char_b, kering):
	output_font.add_kerning_pair(ord(char_a), ord(char_b), kering)


func apply_kering_filter():
	for item in node_kering_pairs_grid.get_children():
		if item is KeringItem:
			item.set_visible(
					(item.char_a == kering_filter_char_a
					or kering_filter_char_a.length() == 0) 
					and (item.char_b == kering_filter_char_b
					or kering_filter_char_b.length() == 0))


func apply_kering_to_filtered_items():
	for item in node_kering_pairs_grid.get_children():
		if item is KeringItem:
			if item.visible:
				item.set_value(node_kering_apply_to_filtered.get_value())


# set filtered items kering by image space in pixel between chars
func autocalculate_kering():
	for item in node_kering_pairs_grid.get_children():
		if item is KeringItem:
			if item.visible:
				var kering = get_space_between_chars(item.char_a, item.char_b)
				
				if item.char_a == " " or item.char_b == " ":
					kering -= (output_char_size.x)
				
				item.set_value(kering - node_autokering.get_value())


# return number of pixels between chars
func get_space_between_chars(char_a, char_b):
	
	# get char index in font charset
	var char_idx_a = output_font_charset.find(char_a)
	var char_idx_b = output_font_charset.find(char_b)
	if char_idx_a == -1 or char_idx_b == -1:
		return 0
	
	# get font texture
	var texture = output_font.get_texture(0).get_data()
	
	# get chars count in texture row
	var chars_count_h: int = texture.get_width() / int(output_charbox_size.x)
	
	# get chars images
	var char_pos_a = Vector2((char_idx_a % chars_count_h) * output_charbox_size.x, floor(char_idx_a / chars_count_h) * output_charbox_size.y) 
	var char_pos_b = Vector2((char_idx_b % chars_count_h) * output_charbox_size.x, floor(char_idx_b / chars_count_h) * output_charbox_size.y) 
	var char_img_a: Image = texture.get_rect(Rect2(char_pos_a + output_charbox_margin, output_char_size))
	var char_img_b: Image = texture.get_rect(Rect2(char_pos_b + output_charbox_margin, output_char_size))
	
	char_img_a.lock()
	char_img_b.lock()
	
	
	# get spaces
	var space_a = 0
	var search_ended_a = false
	for i in range(output_char_size.x - 1, 0, -1):
		for j in range(output_char_size.y):
			var p_color = char_img_a.get_pixel(i, j)
			if not p_color.a == 0:
				search_ended_a = true
				break
		
		if search_ended_a:
			break
		
		space_a += 1
	
	var space_b = 0
	var search_ended_b = false
	for i in range(output_char_size.x):
		for j in range(output_char_size.y):
			var p_color = char_img_b.get_pixel(i, j)
			if not p_color.a == 0:
				search_ended_b = true
				break
		
		if search_ended_b:
			break
		
		space_b += 1
	
	return space_a + space_b


func load_font_texture(path):
	node_create_font_button.disabled = false
	
	use_default_font_texture = false
	
	path_to_font_texture = path
	emit_signal("path_to_font_texture_changed", path_to_font_texture)

func load_default_font_texture():
	node_create_font_button.disabled = false
	
	use_default_font_texture = true
	
	path_to_font_texture = "Default font texture"
	emit_signal("path_to_font_texture_changed", path_to_font_texture)


# on texture file select
func _on_FileDialogOpen_file_selected(path):
	load_font_texture(path)


# on export path selected
func _on_FileDialogSave_file_selected(path):
	ResourceSaver.save(path, output_font)


func open_link_to_test_spritesheet():
	OS.shell_open(link_to_test_spritesheet_file)


func open_link_to_yli():
	OS.shell_open(link_to_yli)


func save_file_from_web():
#	JavaScript.eval('console.log(' + output_font.to_string() + ')')
#	var file = File.new()
#	var a = output_font.take_over_path("res://a.txt")
#	print(output_font.resource_path)
	var file_text = "font file text"
	var code = """
	var link = document.createElement('a');
	link.href = 'data:application/fnt;charset=utf-8,""" + file_text + """'
	link.download = 'filename.fnt'
	link.click();
	"""
	JavaScript.eval(code)


func files_dropped(files, window):
	var ext = files[0].get_extension()
	if ext == "png" or ext == "bmp":
		load_font_texture(files[0])
