tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDepthWorldPosition

func _get_name():
	return "DepthWorldPosition"

func _get_category():
	return "3D"

func _get_subcategory():
	return "Depthmap"

func _get_description():
	return "Returns the world position from the depth texture"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 0

func _get_input_port_name(port):
	return ""

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "world_position"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if mode != Shader.MODE_SPATIAL:
		return ""
		
	var code = preload("depth_world_position.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
		
	var params =  [output_vars[0]]
	return "depth_texture_world_position(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, %s);" % params
