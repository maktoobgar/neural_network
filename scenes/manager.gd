extends Node

class_name Manager

var inputs_count: int = 0
var learning_rate: float = 0
var layers_count: int = 0
var epoch: int = 0
var activation_function: String = ""

var nc_of_each_layer: Array[int] = []
var layers: Dictionary = {}

var inputs: Array[Array] = []
var outputs: Array[Array] = []

func _ready():
	%Neurons.set_right_disconnects(true)

func _show_error() -> void:
	%Popup.title = "Validation Error"
	%Popup.dialog_text = "Not all input fields are valid"
	%Popup.popup_centered()

func _show_file_error() -> void:
	%Popup.title = "Validation Error"
	%Popup.dialog_text = "Not all input fields in file are valid"
	%Popup.popup_centered()

func get_network_inputs() -> void:
	inputs_count = max(int(%InputsCount.value), 0)
	layers_count = int(%LayersCount.value)
	activation_function = %ActivationFunction.value
	%InputsCount.value = str(inputs_count)
	%LayersCount.value = str(layers_count)

func get_learning_inputs() -> void:
	learning_rate = min(float(%LearningRate.value), 1.0)
	epoch = max(int(%Epoch.value), 0)
	%LearningRate.value = str(learning_rate)
	%Epoch.value = str(epoch)

func are_network_inputs_valid() -> bool:
	if inputs_count > 0 && layers_count > 0 && activation_function != "":
		var all_valid = true
		for i in range(%LayersContainer.get_child_count()):
			var node = %LayersContainer.get_child(i)
			nc_of_each_layer[i] = int(node.value)
			if nc_of_each_layer[i] <= 0:
				all_valid = false
		if all_valid:
			return true
	_show_error()
	return false

func are_learning_inputs_valid() -> bool:
	if learning_rate >= 0 && learning_rate <= 1 && epoch >= 1:
		return true
	_show_error()
	return false

func _on_apply_changes_button_up():
	get_network_inputs()
	if not are_network_inputs_valid():
		return

	var prev = ""
	for key in layers:
		if prev == "":
			prev = key
			continue
		if key == "out":
			for i in range(len(layers[prev].all_neurons)):
				%Neurons.disconnect_node(prev, i, key, i)
		elif prev == "in":
			for i in range(len(layers[key].all_neurons)):
				for j in range(len(layers[prev].inputs_outputs)):
					%Neurons.disconnect_node(prev, j, key, i)
		else:
			for i in range(len(layers[prev].all_neurons)):
				for j in range(len(layers[key].all_neurons)):
					%Neurons.disconnect_node(prev, i, key, j)
		prev = key

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
		layer.final_layer = i + 1 == layers_count
		layer.manager = self
		layers[str(i + 1)] = layer
		%Neurons.add_child(layer)

	# Outputs
	var outputs_layer: InputOutputLayer = SceneManager.create_scene_instance("input_output_layer")
	outputs_layer.name = "out"
	outputs_layer.layer_type = Global.LayerType.NeuronsOutput
	outputs_layer.inputs_outputs_count = nc_of_each_layer[len(nc_of_each_layer) - 1]
	outputs_layer.position_offset.x = (layers_count + 1) * 600
	layers["out"] = outputs_layer
	%Neurons.add_child(outputs_layer)
	%ConnectionsButton.disabled = false

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
		var _id = "W " + str(layers[from_node].layer_id) + "-" + str(from_port + 1)
		connect = layers[from_node].all_neurons[from_port].connect_out_neuron(_id, layers[to_node].all_neurons[to_port])
		connect = connect && layers[to_node].all_neurons[to_port].connect_in_neuron(_id, layers[from_node].all_neurons[from_port])
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
		disconnect = layers[to_node].all_neurons[to_port].disconnect_in_neuron("W " + str(layers[from_node].layer_id) + "-" + str(from_port + 1), layers[from_node].all_neurons[from_port])
	# From InputLayer to Layer
	elif is_instance_of(layers[from_node], InputOutputLayer):
		disconnect = layers[to_node].all_neurons[to_port].disconnect_input("W in-" + str(from_port + 1), layers[from_node].inputs_outputs[from_port])
	if disconnect:
		%Neurons.disconnect_node(from_node, from_port, to_node, to_port)

func _on_train_button_button_up():
	get_learning_inputs()
	if not are_learning_inputs_valid():
		return
	for epoch_id in epoch:
		for row_key in range(len(inputs)):
			var one_row_inputs = inputs[row_key]
			var one_row_outputs = outputs[row_key]
			for i in range(len(one_row_inputs)):
				if i < inputs_count:
					layers["in"].inputs_outputs[i].value = str(one_row_inputs[i])
				else:
					layers["out"].inputs_outputs[i - inputs_count].desired_output = str(one_row_inputs[i])
		_run_learning_process()

func _on_test_button_button_up():
	get_learning_inputs()
	if not are_learning_inputs_valid():
		return

func _on_connections_button_button_up():
	var prev = ""
	for key in layers:
		if prev == "":
			prev = key
			continue
		if key == "out":
			for i in range(len(layers[prev].all_neurons)):
				layers[prev].all_neurons[i].connect_output(layers[key].inputs_outputs[i])
				%Neurons.connect_node(prev, i, key, i)
		elif prev == "in":
			for i in range(len(layers[key].all_neurons)):
				for j in range(len(layers[prev].inputs_outputs)):
					layers[key].all_neurons[i].connect_input("W in-" + str(j + 1), layers[prev].inputs_outputs[j])
					%Neurons.connect_node(prev, j, key, i)
		else:
			for i in range(len(layers[prev].all_neurons)):
				for j in range(len(layers[key].all_neurons)):
					var _id = "W " + str(layers[prev].layer_id) + "-" + str(i + 1)
					layers[key].all_neurons[j].connect_in_neuron(_id, layers[prev].all_neurons[i])
					layers[prev].all_neurons[i].connect_out_neuron(_id, layers[key].all_neurons[j])
					%Neurons.connect_node(prev, i, key, j)
		prev = key
	%ConnectionsButton.disabled = true

func _run_learning_process() -> void:
	# Feed Forward
	for key in layers:
		if key == "in" or key == "out":
			continue
		layers[key].feed_forward_all_nodes()

	# Feed Backward
	var keys = layers.keys()
	keys.reverse()
	for key in keys:
		if key != "in" and key != "out":
			layers[key].calculate_delta_all_nodes()
	for key in layers:
		if key != "in" and key != "out":
			layers[key].feed_backward_all_nodes()

func _on_feed_forward_backward_button_button_up():
	get_learning_inputs()
	if not are_learning_inputs_valid():
		return

	for i in epoch:
		_run_learning_process()

func _on_file_dialog_file_selected(path: String):
	if not are_network_inputs_valid():
		return
	inputs = []
	outputs = []
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var splits = content.split("\n", false)
	for line in splits:
		var line_splits = line.strip_escapes().split(",", false)
		if len(line_splits) == inputs_count + nc_of_each_layer[len(nc_of_each_layer) - 1]:
			var inputs_temp = []
			var outputs_temp = []
			for i in len(line_splits):
				var data = line_splits[i].strip_escapes()
				if i < inputs_count:
					inputs_temp.append(float(data))
				else:
					outputs_temp.append(float(data))
			inputs.append(inputs_temp)
			outputs.append(outputs_temp)
	if len(inputs) == 0 or len(outputs) == 0:
		_show_file_error()
		return
	%TrainButton.disabled = false
	%TestButton.disabled = false

func _on_input_button_button_up():
	%FileDialog.popup_centered()
