tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDistanceFade

func _get_name():
	return "DistanceFade"

func _get_category():
	return "3D"
	
func _get_subcategory():
	return "Misc"

func _get_description():
	return "Distance Fade"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "distance_min"
		1:
			return "distance_max"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "alpha"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	if mode != Shader.MODE_SPATIAL:
		return ""
		
	var code = preload("distance_fade.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
	
	# Default values
	var distance_min = 0
	var distance_max = 10
	
	if input_vars[0]:
		distance_min = input_vars[0]
	if input_vars[1]:
		distance_max = input_vars[1]
	
	var params =  [distance_min, distance_max, output_vars[0]]
	return "distance_fade(VERTEX, %s, %s, %s);" % params
	
func _init():
	# Default values for the editor
	# distance_min
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, 0)
	# distance_max
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 10)
