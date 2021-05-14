tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRandomNoise

enum Inputs {
	INPUT,
	W,

	I_COUNT
}

const INPUT_NAMES = ["input", "w"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_name():
	return "RandomNoise"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Pseudo-random number generator"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

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
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
	float gpu_random_float(vec4 co){
		float f = dot(fract(co) + fract(co * 2.32184321231),vec4(129.898,782.33,944.32214932,122.2834234542));
		return fract(sin(f) * 437588.5453);
	}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var w_expr = input_vars[Inputs.W];
	
	if not w_expr:
		w_expr = "0.0"

	return "%s = gpu_random_float(vec4(%s, %s));" % [
		output_vars[0],
		input_vars[Inputs.INPUT],
		w_expr
	]
