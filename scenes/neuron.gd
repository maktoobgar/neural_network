@tool
extends GraphNode

class_name Neuron

var id: int: set = _set_id, get = _get_id
var net: float: set = _set_net, get = _get_net
var output: float: set = _set_output, get = _get_output
var activation_function: String: set = _set_activation_function, get = _get_activation_function
var layer_node: Layer = null
var in_neurons: Array[Neuron] = []
var inputs: Array[InputOutput] = []
var weights: Dictionary = {}

signal output_updated(value: int)

func _append_weight(id: String, value: int) -> void:
	weights[id] = value
	var input: InputControl = SceneManager.create_scene_instance("input_control")
	input.text = id + " => " + str(layer_node.layer_id) + "-" + str(self.id + 1) + ":"
	input.initial_value = "1"
	input.set_meta("id", id)
	input.editable = false
	self.add_child(input)

func _remove_weight(id: String) -> void:
	weights.erase(id)
	for i in range(self.get_child_count()):
		var node = self.get_child(i)
		if node.get_meta("id") == id:
			node.free()
			break

func _set_id(value: int) -> void:
	self.title = Global.get_neuron_name(value + 1)
	id = value

func _get_id() -> int:
	return id

func _set_net(value: float) -> void:
	%Net.value = str(value)

func _get_net() -> float:
	return float(%Net.value)

func _set_output(value: float) -> void:
	output_updated.emit(value)
	%Output.value = str(value)

func _get_output() -> float:
	return float(%Output.value)

func _set_activation_function(value: String) -> void:
	%ActivationFunction.value = value

func _get_activation_function() -> String:
	return %ActivationFunction.value

func _on_close_request():
	%Details.visible = true
	%ValuesContainer.visible = false
	self.size.y = 0
	layer_node.size.y = 0

func _on_show_button_up():
	%Details.visible = false
	%ValuesContainer.visible = true

func connect_neuron(id: String, neuron: Neuron) -> bool:
	if len(inputs) > 0:
		return false
	in_neurons.append(neuron)
	_append_weight(id, 1)
	return true

func connect_input(id: String, input: InputOutput) -> bool:
	if len(in_neurons) > 0:
		return false
	inputs.append(input)
	_append_weight(id, 1)
	return true

func connect_output(input: InputOutput) -> bool:
	output_updated.connect(input.update_value)
	output_updated.emit(output)
	return true

func disconnect_neuron(id: String, neuron: Neuron) -> bool:
	in_neurons.erase(neuron)
	_remove_weight(id)
	return true

func disconnect_input(id: String, input: InputOutput) -> bool:
	inputs.erase(input)
	_remove_weight(id)
	return true

func disconnect_output(input: InputOutput) -> bool:
	output_updated.disconnect(input.update_value)
	return true

func _on_output_text_changed(inputControl: InputControl):
	output_updated.emit(output)
