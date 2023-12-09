@tool
extends Node

class_name InputControl

@export var text: String = "" : set = _set_text, get = _get_text
@export var options: Array[String] = []
@export var with_label: bool = true : set = _set_with_label, get = _get_with_label
@export var editable: bool = false : set = _set_editable, get = _get_editable
@export var initial_value: String = ""
@export var force_int: bool = false
@export var force_float: bool = false
@export var min_value: float = 0
@export var max_value: float = 0
@export var force_min: bool = false
@export var force_max: bool = false
@export_enum("Text", "OptionButton") var input_type: String = "Text" : set = _set_type, get = _get_type

var value: String = "" : set = _set_value, get = _get_value
var input: Control = null

signal text_changed(inputControl: InputControl)
signal item_selected(inputControl: InputControl)

func create_input_control(value: String) -> void:
	if value == "Text":
		var lineEdit = LineEdit.new()
		_delete_current_input()
		_make_current_input(lineEdit)
		lineEdit.text_changed.connect(_text_changed)
		if initial_value != "":
			lineEdit.text = initial_value
	elif value == "OptionButton":
		var optionButton = OptionButton.new()
		for option in options:
			optionButton.add_item(option)
		_delete_current_input()
		_make_current_input(optionButton)
		optionButton.item_selected.connect(_item_selected)
		if initial_value != "":
			optionButton.selected = int(initial_value)

func _ready() -> void:
	create_input_control(input_type)
	editable = false
	%Label.text = text
	%Label.visible = with_label

func _delete_current_input() -> void:
	if input != null:
		input.queue_free()
		input = null

func _make_current_input(node: Node) -> void:
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input = node
	self.add_child(node)
	await self.ready

func _set_text(value: String) -> void:
	%Label.text = value

func _get_text() -> String:
	return %Label.text

func _set_with_label(value: bool) -> void:
	%Label.visible = value

func _get_with_label() -> bool:
	return with_label

func _set_editable(value: bool) -> void:
	if !input:
		await self.ready
	if input_type == "OptionButton":
		input.disabled = !value
	elif input_type == "Text":
		input.editable = value

func _get_editable() -> bool:
	if input_type == "OptionButton":
		return !input.disabled
	elif input_type == "Text":
		return input.editable
	return false

func _set_value(value: String) -> void:
	if input_type == "Text":
		input.text = value

func _get_value() -> String:
	if input_type == "Text":
		return input.text
	elif input_type == "OptionButton":
		return options[input.selected]
	return ""

func _set_type(value: String) -> void:
	create_input_control(value)
	input_type = value

func _get_type() -> String:
	return input_type

func _text_changed(text: String) -> void:
	if force_int:
		_force_int()
	if force_float:
		_force_float()
	if force_min:
		_min_force()
	if force_max:
		_max_force()
	text_changed.emit(self)

func _item_selected(index: int) -> void:
	item_selected.emit(self)

func _force_int() -> void:
	var value = int(input.text)
	if value == 0 && input.text == "":
		return
	if str(value) != input.text:
		input.text = str(value)

func _force_float() -> void:
	var value = float(input.text)
	if value == 0 && input.text == "":
		return
	if str(value) != input.text.trim_suffix("."):
		input.text = str(value)

func _min_force():
	var value = float(input.text)
	if value < min_value:
		input.text = str(min_value)

func _max_force():
	var value = float(input.text)
	if value > max_value:
		input.text = str(max_value)
