tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRandomNoise

enum Params {
	INPUT,
	W,

	P_COUNT
}

const PARAM_NAMES = ["input", "w"];
const PARAM_TYPES = [
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
	return Params.P_COUNT

func _get_input_port_name(port):
	return PARAM_NAMES[port]

func _get_input_port_type(port):
	return PARAM_TYPES[port]

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "result"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return """
	float rand(vec4 co){
		float f = dot(fract(co),vec4(129.898,782.33,944.32214932,122.2834234542));
		return fract(sin(f) * 437588.5453);
	}
	"""

func _get_code(input_vars, output_vars, mode, type):
	var w_expr = input_vars[Params.W];
	
	if not w_expr:
		w_expr = "0.0"
	
	return "%s = rand(vec4(%s, %s));" % [
		output_vars[0],
		input_vars[Params.INPUT],
		w_expr
	]
