@tool
extends GraphNode

class_name Neuron

var id: int: set = _set_id, get = _get_id
var net: float: set = _set_net, get = _get_net
var value: float: set = _set_value, get = _get_value
var delta: float: set = _set_delta, get = _get_delta
var b: float: set = _set_b, get = _get_b
var activation_function: String: set = _set_activation_function, get = _get_activation_function
var layer_node: Layer = null
var in_neurons: Dictionary = {}
var out_neurons: Dictionary = {}
var inputs: Dictionary = {}
var output: InputOutput = null
var weights: Dictionary = {}
var weights_nodes: Dictionary = {}
var center: Array = []
var active_bias: bool = false

signal value_updated(value: float)

func _append_weight(id: String, value: float) -> void:
	weights[id] = value
	var input: InputControl = SceneManager.create_scene_instance("input_control")
	input.text = id + " => " + str(layer_node.layer_id) + "-" + str(self.id + 1) + ":"
	if activation_function == "Gaussian":
		input.initial_value = "1"
	else:
		input.initial_value = str(randf_range(0, 1))
	input.set_meta("id", id)
	input.editable = false
	weights_nodes[id] = input
	%Weights.add_child(input)

func _remove_weight(id: String) -> void:
	weights.erase(id)
	weights_nodes[id].free()

func update_weight_on_input(id: String, value: float) -> void:
	weights_nodes[id].value = str(value)

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

func _set_delta(value: float) -> void:
	%Delta.value = str(value)

func _get_delta() -> float:
	return float(%Delta.value)

func _set_b(value: float) -> void:
	%B.value = str(value)

func _get_b() -> float:
	return float(%B.value)

func _set_activation_function(value: String) -> void:
	%ActivationFunction.value = value
	if value != "Gaussian":
		for key in weights_nodes.keys():
			weights_nodes[key].value = str(randf_range(0, 1))
	else:
		for key in weights_nodes.keys():
			weights_nodes[key].value = "1"

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

func connect_in_neuron(id: String, neuron: Neuron) -> bool:
	if len(inputs) > 0:
		return false
	in_neurons[id] = neuron
	_append_weight(id, 0.01)
	return true

func connect_out_neuron(id: String, neuron: Neuron) -> bool:
	out_neurons[id+"|"+str(neuron.id)] = neuron
	return true

func connect_input(id: String, inputOutput: InputOutput) -> bool:
	if len(in_neurons) > 0:
		return false
	inputs[id] = inputOutput
	_append_weight(id, 0.01)
	return true

func connect_output(inputOutput: InputOutput) -> bool:
	output = inputOutput
	value_updated.connect(inputOutput.update_value)
	value_updated.emit(value)
	return true

func disconnect_in_neuron(id: String, neuron: Neuron) -> bool:
	in_neurons.erase(id)
	_remove_weight(id)
	return true

func disconnect_input(id: String, inputOutput: InputOutput) -> bool:
	inputs.erase(id)
	_remove_weight(id)
	return true

func disconnect_output(inputOutput: InputOutput) -> bool:
	output = null
	value_updated.disconnect(inputOutput.update_value)
	return true

func _on_output_text_changed(inputControl: InputControl):
	value_updated.emit(value)

func feed_forward() -> void:
	var inputs_or_neurons: Dictionary = {}
	if len(in_neurons) > 0:
		inputs_or_neurons = in_neurons
	elif len(inputs) > 0:
		inputs_or_neurons = inputs
	if activation_function == "Gaussian" and len(center) != 0:
		var new_value: float = 0
		for i in range(len(Global.learning_point)):
			new_value += pow(center[i] - Global.learning_point[i], 2)
		net = new_value
		value = Global.calculate_neuron_output(net, activation_function, layer_node.manager.variance)
	else:
		var new_value: float = 0
		for key in inputs_or_neurons:
			new_value += inputs_or_neurons[key].value * weights[key]
		if active_bias:
			net = new_value + b
		else:
			net = new_value
		value = Global.calculate_neuron_output(net, activation_function)

func calculate_delta() -> void:
	if activation_function == "Gaussian":
		return
	var y_derivative = Global.calculate_derivative_neuron_output(net, activation_function, layer_node.manager.variance)
	if layer_node.final_layer:
		if output:
			delta = y_derivative * (output.desired_output - value)
		return
	var sigma = 0
	for key in out_neurons:
		var weight_key = key.split("|")[0]
		sigma += out_neurons[key].weights[weight_key] * out_neurons[key].delta
	delta = y_derivative * sigma

func feed_backward() -> void:
	var inputs_or_neurons: Dictionary = {}
	if len(in_neurons) > 0:
		inputs_or_neurons = in_neurons
	elif len(inputs) > 0:
		inputs_or_neurons = inputs
	if activation_function == "Gaussian":
		return
	if active_bias:
		b = b + layer_node.manager.learning_rate * delta * 1
	for key in weights:
		var delta_w = layer_node.manager.learning_rate * delta * inputs_or_neurons[key].value
		var new_weight = weights[key] + delta_w
		weights[key] = new_weight
		update_weight_on_input(key, new_weight)
	if output != null:
		return

	for key in out_neurons:
		var weight_key = key.split("|")[0]
		var delta_w = layer_node.manager.learning_rate * out_neurons[key].delta * value
		var new_weight = out_neurons[key].weights[weight_key] + delta_w
		out_neurons[key].weights[weight_key] = new_weight
		out_neurons[key].update_weight_on_input(weight_key, new_weight)
