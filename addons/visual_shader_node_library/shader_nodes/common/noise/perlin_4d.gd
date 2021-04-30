tool
extends VisualShaderNodeCustom
class_name VisualShaderNodePerlinNoise4D

enum Params {
	OFFSET,
	OFFSET_W,
	PERIOD,
	PERIOD_W,
	SCALE,
	SCALE_W,
	
	P_COUNT
}

const PARAM_NAMES = ["offset", "offset_w", "period", "period_w", "scale", "scale_w"];
const PARAM_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR, VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR, VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR, VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_name():
	return "PerlinNoise4D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Classic Perlin-Noise-4D function (by Curly-Brace)"

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
	var code = preload("perlin_4d.shader").code
	code = code.replace("shader_type spatial;", "")
	return code

func get_input_vector_code(xyz_var, w_var, default):
	if not xyz_var:
		xyz_var = "%s, %s, %s" % [default, default, default]
	
	if not w_var:
		w_var = default

	return "vec4(%s, %s)" % [xyz_var, w_var]

func _get_code(input_vars, output_vars, mode, type):
	var offset = get_input_vector_code(input_vars[Params.OFFSET], input_vars[Params.OFFSET_W], "0.0");
	
	if input_vars[Params.SCALE] or input_vars[Params.SCALE_W]:
		offset = "%s * %s" % [offset, get_input_vector_code(input_vars[Params.SCALE], input_vars[Params.SCALE_W], "1.0")]

	if input_vars[Params.PERIOD] or input_vars[Params.PERIOD_W]:
		# periodic noise
		return "%s = perlin_noise_4d_p(%s, %s);" % [
			output_vars[0],
			offset,
			get_input_vector_code(input_vars[Params.PERIOD], input_vars[Params.PERIOD_W], "1.0")
		]
	else:
		var params = [output_vars[0], offset]

		return "%s = perlin_noise_4d_np(%s);" % params
