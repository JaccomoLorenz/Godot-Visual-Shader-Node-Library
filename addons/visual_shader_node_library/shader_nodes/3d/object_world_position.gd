tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeObjectWorldPosition

func _get_name():
	return "ObjectWorldPosition"

func _get_category():
	return "3D"
	
func _get_subcategory():
	return "Object"

func _get_description():
	return "Object position in world space"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 0

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

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL:
		return ""
		
	return output_vars[0] + " = WORLD_MATRIX[3].xyz;"
