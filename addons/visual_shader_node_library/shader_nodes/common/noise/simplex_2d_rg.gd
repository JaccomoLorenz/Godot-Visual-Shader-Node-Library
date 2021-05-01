tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSimplexNoise2DWithRotatingGradient

enum Params {
	OFFSET,
	PERIOD,
	SCALE,
	GRADIENT_ROTATION,
	
	P_COUNT
}

const PARAM_NAMES = ["offset", "period", "scale", "gradient_rotation"];
const PARAM_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR
]

enum Outputs {
	NOISE,
	GRADIENT,
	
	O_COUNT
}

const OUTPUT_NAMES = ["noise", "gradient"]
const OUTPUT_TYPES = [VisualShaderNode.PORT_TYPE_SCALAR, VisualShaderNode.PORT_TYPE_VECTOR]

func _get_name():
	return "SimplexNoise2DRG"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Simplex noise with rotating gradients and analytical derivative"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return Params.P_COUNT

func _get_input_port_name(port):
	return PARAM_NAMES[port]

func _get_input_port_type(port):
	return PARAM_TYPES[port]

func _get_output_port_count():
	return Outputs.O_COUNT

func _get_output_port_name(port):
	return OUTPUT_NAMES[port]

func _get_output_port_type(port):
	return OUTPUT_TYPES[port]

func _get_global_code(mode):
	var code = preload("simplex_2d_rg.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Params.OFFSET];
	
	if not offset:
		offset = "vec2(0.0, 0.0)"
	else:
		offset = "(%s).xy" % [offset]

	if input_vars[Params.SCALE]:
		offset = "(%s).xy * (%s).xy" % [offset, input_vars[Params.SCALE]]
		
	var gradient_rotation = input_vars[Params.GRADIENT_ROTATION]
	
	if not gradient_rotation:
		gradient_rotation = "0.0"
	
	var result_assignment = ""

	if input_vars[Params.PERIOD]:
		# periodic noise
		result_assignment = "vec3 result = simplex_noise_2d_rg_p(%s.xy, (%s).xy, %s);" % [
			offset,
			input_vars[Params.PERIOD],
			gradient_rotation
		]
	else:
		result_assignment = " vec3 result = simplex_noise_2d_rg_np(%s.xy, %s);" % [
			offset,
			gradient_rotation
		]
	
	var noise_assignment = ""
	
	if output_vars[Outputs.NOISE]:
		noise_assignment = "%s = result.x;" % [output_vars[Outputs.NOISE]];
	
	var gradient_assignment = ""
	
	if output_vars[Outputs.GRADIENT]:
		gradient_assignment = "%s = vec3(result.xy, 0.0);" % [output_vars[Outputs.GRADIENT]]

	return """
	%s
	%s
	%s
	""" % [result_assignment, noise_assignment, gradient_assignment]
