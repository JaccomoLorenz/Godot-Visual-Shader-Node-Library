tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeFromPolar2D

func _get_name():
	return "FromPolar2D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Misc"

func _get_description():
	return "Converts 2D polar coordinates to cartesian coordinates"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

enum Inputs {
	A,
	D,
	ORIGIN,

	I_COUNT
};
const INPUT_NAMES = ["a", "d", "origin"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR
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
	return "xy"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	return ""

func _get_code(input_vars, output_vars, mode, type):
	var origin = input_vars[Inputs.ORIGIN]
	
	if origin:
		origin = " + %s.xy" % [origin]
	else:
		origin = ""

	return """
		float a = %s, d = %s;
		vec2 res = vec2(sin(a), cos(a)) * d%s;
		%s = vec3(res, 0.0);
	""" % [input_vars[Inputs.A], input_vars[Inputs.D], origin, output_vars[0]]
