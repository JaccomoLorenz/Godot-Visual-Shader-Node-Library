tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSimplexNoise3D

enum Inputs {
	OFFSET,
	SCALE,
	
	I_COUNT
}

const INPUT_NAMES = ["offset", "scale"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR
]

enum Outputs {
	NOISE,
	GRADIENT,
	
	O_COUNT
}

const OUTPUT_NAMES = ["noise", "gradient"]
const OUTPUT_TYPES = [VisualShaderNode.PORT_TYPE_SCALAR, VisualShaderNode.PORT_TYPE_VECTOR]

func _get_name():
	return "SimplexNoise3D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Textureless 3D simplex noise with analytic gradient output"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

func _get_output_port_count():
	return Outputs.O_COUNT

func _get_output_port_name(port):
	return OUTPUT_NAMES[port]

func _get_output_port_type(port):
	return OUTPUT_TYPES[port]

func _get_global_code(mode):
	var code = preload("simplex_3d.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Inputs.OFFSET];
	
	if not offset:
		offset = "vec3(0.0)"
	else:
		offset = "%s" % [offset]

	offset = "%s * %s" % [offset, input_vars[Inputs.SCALE]]

	return """
		%s = simplex_noise_3d(%s, %s);
	""" % [output_vars[Outputs.NOISE], offset, output_vars[Outputs.GRADIENT]]

func _init():
	if not get_input_port_default_value(Inputs.SCALE):
		set_input_port_default_value(Inputs.SCALE, Vector3(1.0, 1.0, 1.0))
