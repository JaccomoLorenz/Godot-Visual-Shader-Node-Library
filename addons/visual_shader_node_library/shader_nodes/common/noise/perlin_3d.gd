tool
extends VisualShaderNodeCustom
class_name VisualShaderNodePerlinNoise3D

enum Params {
	OFFSET,
	PERIOD,
	SCALE,
	
	P_COUNT
}

const PARAM_NAMES = ["offset", "period", "scale"];
const PARAM_TYPES = [
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
	return "Classic Perlin-Noise-3D function (by Curly-Brace)"

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
	var code = preload("perlin_3d.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Params.OFFSET];
	
	if not offset:
		offset = "vec3(0.0, 0.0, 0.0)"
	else:
		offset = "%s" % [offset]

	if input_vars[Params.SCALE]:
		offset = "%s * %s" % [offset, input_vars[Params.SCALE]]

	if input_vars[Params.PERIOD]:
		# periodic noise
		return "%s = perlin_noise_3d_p(%s, %s);" % [
			output_vars[0],
			offset,
			input_vars[Params.PERIOD]
		]
	else:
		return "%s = perlin_noise_3d_np(%s);" % [output_vars[0], offset]
