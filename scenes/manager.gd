extends Node

var inputs_count: int = 0
var learning_rate: float = 0
var layers_count: int = 0
var epoch: int = 0
var activation_function: String = ""

var nc_of_each_layer: Array[int] = []
var layers: Dictionary = {}

func _ready():
	%Neurons.set_right_disconnects(true)

func get_inputs() -> void:
	inputs_count = max(int(%InputsCount.value), 0)
	learning_rate = min(float(%LearningRate.value), 1.0)
	layers_count = int(%LayersCount.value)
	epoch = max(int(%Epoch.value), 0)
	activation_function = %ActivationFunction.value
	%InputsCount.value = str(inputs_count)
	%LearningRate.value = str(learning_rate)
	%LayersCount.value = str(layers_count)
	%Epoch.value = str(epoch)

func are_inputs_valid() -> bool:
	if inputs_count > 0 && learning_rate > 0 && layers_count > 0 && epoch > 0 && activation_function != "None":
		var all_valid = true
		for i in range(%LayersContainer.get_child_count()):
			var node = %LayersContainer.get_child(i)
			nc_of_each_layer[i] = int(node.value)
			if nc_of_each_layer[i] <= 0:
				all_valid = false
		if all_valid:
			return true
	%Popup.title = "Validation Error"
	%Popup.dialog_text = "Not all input fields are valid"
	%Popup.popup_centered()
	return false

func _on_apply_changes_button_up():
	get_inputs()
	if not are_inputs_valid():
		return

	# Clean All
	for i in range(%Neurons.get_child_count()):
		%Neurons.get_child(0).free()
		layers = {}

	# Inputs
	var inputs_layer: InputOutputLayer = SceneManager.create_scene_instance("input_output_layer")
	inputs_layer.name = "in"
	inputs_layer.layer_type = Global.LayerType.NeuronsInput
	inputs_layer.inputs_outputs_count = inputs_count
	layers["in"] = inputs_layer
	%Neurons.add_child(inputs_layer)

	# Layers Of Neurons
	for i in range(layers_count):
		var layer: Layer = SceneManager.create_scene_instance("layer")
		layer.name = str(i + 1)
		layer.layer_id = i + 1
		layer.neurons_count = nc_of_each_layer[i]
		layer.position_offset.x = (i + 1) * 600
		layer.activation_function = activation_function
		layers[str(i + 1)] = layer
		%Neurons.add_child(layer)

	# Outputs
	var outputs_layer: InputOutputLayer = SceneManager.create_scene_instance("input_output_layer")
	outputs_layer.name = "out"
	outputs_layer.layer_type = Global.LayerType.NeuronsOutput
	outputs_layer.inputs_outputs_count = nc_of_each_layer[len(nc_of_each_layer) - 1]
	outputs_layer.position_offset.x = (layers_count + 1) * 600
	layers["out"] = outputs_layer
	outputs_layer.ready.connect(_connect_all_lines)
	%Neurons.add_child(outputs_layer)

func _on_layers_count_text_changed(inputControl: InputControl):
	var count = int(%LayersCount.value)
	for i in range(count):
		if %LayersContainer.get_child_count() - 1 >= i:
			continue
		var input: InputControl = SceneManager.create_scene_instance("input_control")
		input.text = "NC Layer " + str(i + 1) + ":"
		input.set_meta("layer_id", i)
		input.force_int = true
		input.text_changed.connect(_layer_text_changed)
		input.initial_value = "0"
		nc_of_each_layer.append(0)
		%LayersContainer.add_child(input)

	var difference = %LayersContainer.get_child_count() - count
	for i in range(difference):
		nc_of_each_layer.pop_back()
		%LayersContainer.remove_child(%LayersContainer.get_child(%LayersContainer.get_child_count() - 1))

func _layer_text_changed(inputControl: InputControl) -> void:
	var value = int(inputControl.value)
	var layer_id = inputControl.get_meta("layer_id")
	nc_of_each_layer[layer_id] = value

func _on_neurons_connection_request(from_node, from_port, to_node, to_port):
	var connect = false
	# From Layer To OutputLayer
	if is_instance_of(layers[from_node], Layer) && is_instance_of(layers[to_node], InputOutputLayer):
		connect = layers[from_node].all_neurons[from_port].connect_output(layers[to_node].inputs_outputs[to_port])
	# From Layer to Layer
	elif is_instance_of(layers[from_node], Layer):
		connect = layers[to_node].all_neurons[to_port].connect_neuron("W " + str(layers[from_node].layer_id) + "-" + str(from_port + 1), layers[from_node].all_neurons[from_port])
	# From InputLayer to Layer
	elif is_instance_of(layers[from_node], InputOutputLayer):
		connect = layers[to_node].all_neurons[to_port].connect_input("W in-" + str(from_port + 1), layers[from_node].inputs_outputs[from_port])
	if connect:
		%Neurons.connect_node(from_node, from_port, to_node, to_port)

func _on_neurons_disconnection_request(from_node, from_port, to_node, to_port):
	var disconnect = false
	# From Layer To OutputLayer
	if is_instance_of(layers[from_node], Layer) && is_instance_of(layers[to_node], InputOutputLayer):
		disconnect = layers[from_node].all_neurons[from_port].disconnect_output(layers[to_node].inputs_outputs[to_port])
	# From Layer to Layer
	elif is_instance_of(layers[from_node], Layer):
		disconnect = layers[to_node].all_neurons[to_port].disconnect_neuron("W " + str(layers[from_node].layer_id) + "-" + str(from_port + 1), layers[from_node].all_neurons[from_port])
	# From InputLayer to Layer
	elif is_instance_of(layers[from_node], InputOutputLayer):
		disconnect = layers[to_node].all_neurons[to_port].disconnect_input("W in-" + str(from_port + 1), layers[from_node].inputs_outputs[from_port])
	if disconnect:
		%Neurons.disconnect_node(from_node, from_port, to_node, to_port)

func _connect_all_lines() -> void:
	var prev = null
	for layer in layers:
		if prev == null:
			prev = layer
			continue
