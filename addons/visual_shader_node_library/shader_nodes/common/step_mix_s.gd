tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeStepMixS

func _get_name():
	return "StepMixS"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Functions"

func _get_description():
	return "Equivalent of MixS with output of Step or Smoothstep as coefficient"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

enum Inputs {
	A,
	B,
	K,
	THRESHOLD,
	SMOOTHNESS,
	
	I_COUNT
};
const INPUT_NAMES = ["a", "b", "k", "threshold", "smoothness"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR
];

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "result"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return ""

func _get_code(input_vars, output_vars, mode, type):
	var threshold = input_vars[Inputs.THRESHOLD];
	
	if not threshold:
		threshold = "0.0"
	
	var step;
	
	var smoothness = input_vars[Inputs.SMOOTHNESS]
	
	if smoothness:
		step = "smoothstep(%s - %s, %s + %s, %s)" % [
			threshold, smoothness,
			threshold, smoothness,
			input_vars[Inputs.K]
		]
	else:
		step = "step(%s, %s)" % [threshold, input_vars[Inputs.K]]
		
	var a = input_vars[Inputs.A]
	
	var b = input_vars[Inputs.B]

	return """
		%s = mix(%s, %s, %s);
	""" % [output_vars[0], a, b, step]


func _init():
	if not get_input_port_default_value(Inputs.A):
		set_input_port_default_value(Inputs.A, Vector3(1.0,1.0,1.0))
	if not get_input_port_default_value(Inputs.B):
		set_input_port_default_value(Inputs.B, Vector3(0.0,0.0,0.0))
	if not get_input_port_default_value(Inputs.THRESHOLD):
		set_input_port_default_value(Inputs.THRESHOLD, 0.0)
