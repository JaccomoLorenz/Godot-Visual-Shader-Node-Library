tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeEmissionAdd

func _get_name():
	return "EmissionAdd"

func _get_category():
	return "3D"
	
func _get_subcategory():
	return "Emission"

func _get_description():
	return "Calculates emission. (Operator=Add)"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "color"
		1:
			return "texture"
		2:
			return "energy"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "emission"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if mode != Shader.MODE_SPATIAL:
		return ""
		
	var code = preload("emission_add.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
	
	# Default values
	var color = "vec3(1.0, 1.0, 1.0)"
	var texture = "vec3(0.0, 0.0, 0.0)"
	var energy = "1.0"

	if input_vars[0]:
		color = input_vars[0]
	if input_vars[1]:
		texture = input_vars[1]
	if input_vars[2]:
		energy = input_vars[2]
		
	var params =  [color, texture, energy, output_vars[0]]
	return "emission_add(%s, %s, %s, %s);" % params
	
func _init():
	# Default values for the editor
	# energy
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 1.0)
