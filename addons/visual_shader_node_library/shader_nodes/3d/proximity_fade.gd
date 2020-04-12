tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeProximityFade

func _get_name():
	return "ProximityFade"

func _get_category():
	return "3D"
	
func _get_subcategory():
	return "Misc"

func _get_description():
	return "Proximity Fade"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "distance"
		1:
			return "(depth_world_position)"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR

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
		
	var code = preload("proximity_fade.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
	
	# Default values
	var distance = "0.0"
	# Use own depth_texture_world_position function if it is not passed via input port
	var code = "vec3 proximity_fade_depth_p;\n"
	code += "proximity_fade_depth_pos(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, proximity_fade_depth_p);\n"
	var pos = "proximity_fade_depth_p"

	
	if input_vars[0]:
		distance = input_vars[0]
	if input_vars[1]:
		pos = input_vars[1]
	
	var params =  [pos, distance, output_vars[0]]
	return code + "proximity_fade(%s, VERTEX, %s, %s);" % params
	
func _init():
	# Default values for the editor
	# distance
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, 1.0)
