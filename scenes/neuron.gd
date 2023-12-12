@tool
extends GraphNode

class_name Neuron

var id: int: set = _set_id, get = _get_id
var net: float: set = _set_net, get = _get_net
var value: float: set = _set_value, get = _get_value
var delta: float: set = _set_delta, get = _get_delta
var activation_function: String: set = _set_activation_function, get = _get_activation_function
var layer_node: Layer = null
var in_neurons: Dictionary = {}
var out_neurons: Dictionary = {}
var inputs: Dictionary = {}
var output: InputOutput = null
var weights: Dictionary = {}
var weights_nodes: Dictionary = {}

signal value_updated(value: int)

func _append_weight(id: String, value: int) -> void:
	weights[id] = value
	var input: InputControl = SceneManager.create_scene_instance("input_control")
	input.text = id + " => " + str(layer_node.layer_id) + "-" + str(self.id + 1) + ":"
	input.initial_value = "1"
	input.set_meta("id", id)
	input.editable = false
	weights_nodes[id] = input
	%Weights.add_child(input)

func _remove_weight(id: String) -> void:
	weights.erase(id)
	weights_nodes[id].free()

func update_weight_on_input(id: String, value: float) -> void:
	print(value)
	print(str(value))
	print("---------")
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

func connect_in_neuron(id: String, neuron: Neuron) -> bool:
	if len(inputs) > 0:
		return false
	in_neurons[id] = neuron
	_append_weight(id, 1.0)
	return true

func connect_out_neuron(id: String, neuron: Neuron) -> bool:
	out_neurons[id] = neuron
	return true

func connect_input(id: String, inputOutput: InputOutput) -> bool:
	if len(in_neurons) > 0:
		return false
	inputs[id] = inputOutput
	_append_weight(id, 1.0)
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
	var new_value: float = 0
	for key in inputs_or_neurons:
		new_value += inputs_or_neurons[key].value * weights[key]
	net = new_value
	value = Global.calculate_neuron_output(net, activation_function)

func calculate_delta() -> void:
	var y_derivative = Global.calculate_derivative_neuron_output(net, activation_function)
	if layer_node.final_layer:
		delta = y_derivative * (output.desired_output - value)
		return
	var sigma = 0
	for key in out_neurons:
		sigma += out_neurons[key].weights[key] * out_neurons[key].delta
	delta = y_derivative * sigma

func feed_backward() -> void:
	if id == 0:
		for key in weights:
			var delta_w = layer_node.manager.learning_rate * delta * inputs[key].value
			var new_weight = weights[key] + delta_w
			weights[key] = new_weight
			update_weight_on_input(key, new_weight)
		if output != null:
			return
	elif output != null:
		return

	for key in out_neurons:
		var delta_w = layer_node.manager.learning_rate * out_neurons[key].delta * value
		var new_weight = out_neurons[key].weights[key] + delta_w
		out_neurons[key].weights[key] = new_weight
		out_neurons[key].update_weight_on_input(id, new_weight)
