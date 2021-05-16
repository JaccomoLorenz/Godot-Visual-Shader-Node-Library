tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSimplexNoise4D

enum Inputs {
	OFFSET,
	OFFSET_W,
	SCALE,
	SCALE_W,
	
	I_COUNT
}

const INPUT_NAMES = ["offset", "offset_w", "scale", "scale_w"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR, VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR, VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_name():
	return "SimplexNoise4D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Textureless 4D simplex noise"

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
	var code = preload("simplex_4d.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func get_input_vector_code(xyz_var, w_var, default):
	if not xyz_var:
		xyz_var = "%s, %s, %s" % [default, default, default]
	
	if not w_var:
		w_var = default

	return "vec4(%s, %s)" % [xyz_var, w_var]

func _get_code(input_vars, output_vars, mode, type):
	var offset = get_input_vector_code(input_vars[Inputs.OFFSET], input_vars[Inputs.OFFSET_W], "0.0");
	
	offset = "%s * %s" % [offset, get_input_vector_code(input_vars[Inputs.SCALE], input_vars[Inputs.SCALE_W], "1.0")]

	var params = [output_vars[0], offset]

	return "%s = simplex_noise_4d(%s);" % params

func _init():
	if not get_input_port_default_value(Inputs.SCALE):
		set_input_port_default_value(Inputs.SCALE, Vector3(1.0, 1.0, 1.0))
	if not get_input_port_default_value(Inputs.SCALE_W):
		set_input_port_default_value(Inputs.SCALE_W, 1.0)
