tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeReadNormalMap

func _get_name():
	return "ReadNormalMap"

func _get_category():
	return "Common"
	
func _get_subcategory():
	return "Misc"

func _get_description():
	return "Returns the view space normal based on data from a specified normal map."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0:
			return "normalmap_data"
		1:
			return "normal"
		2:
			return "tangent"
		3:
			return "bitangent"
		4:
			return "normal depth"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "normal"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if mode != Shader.MODE_SPATIAL:
		return ""
	
	var code = preload("read_normalmap.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
	
	# Default values
	var normalmap_data = "vec3(0.5, 0.5, 1.0)"
	var normal = "NORMAL"
	var tangent = "TANGENT"
	var binormal = "BINORMAL"
	var normal_depth = "NORMALMAP_DEPTH"
	
	if input_vars[0]:
		normalmap_data = input_vars[0]
	if input_vars[1]:
		normal = input_vars[1]
	if input_vars[2]:
		tangent = input_vars[2]
	if input_vars[3]:
		binormal = input_vars[3]
	if input_vars[4]:
		normal_depth = input_vars[4]
	
	var params =  [output_vars[0], normalmap_data, normal, tangent, binormal, normal_depth]
	return "%s = read_normalmap(%s, %s, %s, %s, %s);" % params
