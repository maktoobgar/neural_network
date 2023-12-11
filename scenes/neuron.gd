@tool
extends GraphNode

class_name Neuron

var id: int: set = _set_id, get = _get_id
var net: float: set = _set_net, get = _get_net
var value: float: set = _set_value, get = _get_value
var activation_function: String: set = _set_activation_function, get = _get_activation_function
var layer_node: Layer = null
var in_neurons: Dictionary = {}
var inputs: Dictionary = {}
var weights: Dictionary = {}

signal value_updated(value: int)

func _append_weight(id: String, value: int) -> void:
	weights[id] = value
	var input: InputControl = SceneManager.create_scene_instance("input_control")
	input.text = id + " => " + str(layer_node.layer_id) + "-" + str(self.id + 1) + ":"
	input.initial_value = "1"
	input.set_meta("id", id)
	input.editable = false
	%Weights.add_child(input)

func _remove_weight(id: String) -> void:
	weights.erase(id)
	for i in range(%Weights.get_child_count()):
		var node = %Weights.get_child(i)
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

func _set_value(value: float) -> void:
	value_updated.emit(value)
	%Output.value = str(value)

func _get_value() -> float:
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
	in_neurons[id] = neuron
	_append_weight(id, 1.0)
	return true

func connect_input(id: String, input: InputOutput) -> bool:
	if len(in_neurons) > 0:
		return false
	inputs[id] = input
	_append_weight(id, 1.0)
	return true

func connect_output(input: InputOutput) -> bool:
	value_updated.connect(input.update_value)
	value_updated.emit(value)
	return true

func disconnect_neuron(id: String, neuron: Neuron) -> bool:
	in_neurons.erase(id)
	_remove_weight(id)
	return true

func disconnect_input(id: String, input: InputOutput) -> bool:
	inputs.erase(id)
	_remove_weight(id)
	return true

func disconnect_output(input: InputOutput) -> bool:
	value_updated.disconnect(input.update_value)
	return true

func _on_output_text_changed(inputControl: InputControl):
	value_updated.emit(value)

func feed_forward() -> void:
	var inputs_or_neurons: Dictionary = {}
	if len(in_neurons) > 0:
		inputs_or_neurons = in_neurons
	elif len(inputs) > 0:
		inputs_or_neurons = inputs
	var new_value: float = 0
	for key in inputs_or_neurons:
		new_value += inputs_or_neurons[key].value * weights[key]
	net = new_value
	value = Global.calculate_neuron_output(net, activation_function)
