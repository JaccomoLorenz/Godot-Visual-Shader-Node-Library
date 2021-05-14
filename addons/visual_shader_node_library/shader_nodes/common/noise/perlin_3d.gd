tool
extends VisualShaderNodeCustom
class_name VisualShaderNodePerlinNoise3D

enum Inputs {
	OFFSET,
	PERIOD,
	SCALE,
	
	I_COUNT
}

const INPUT_NAMES = ["offset", "period", "scale"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR
]

func _get_name():
	return "PerlinNoise3D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Textureless 3D Perlin noise"

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
	var code = preload("perlin_3d.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Inputs.OFFSET];
	
	if not offset:
		offset = "vec3(0.0, 0.0, 0.0)"
	else:
		offset = "%s" % [offset]

	offset = "%s * %s" % [offset, input_vars[Inputs.SCALE]]

	if input_vars[Inputs.PERIOD]:
		# periodic noise
		return "%s = perlin_noise_3d_p(%s, %s);" % [
			output_vars[0],
			offset,
			input_vars[Inputs.PERIOD]
		]
	else:
		return "%s = perlin_noise_3d_np(%s);" % [output_vars[0], offset]

func _init():
	if not get_input_port_default_value(Inputs.SCALE):
		set_input_port_default_value(Inputs.SCALE, Vector3(1.0, 1.0, 1.0))
