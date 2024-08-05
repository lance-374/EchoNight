extends CanvasLayer

@export var fog_density : float = 0.4

var fog_material : ShaderMaterial

func _ready():
	var color_rect = $ColorRect
	fog_material = color_rect.material as ShaderMaterial
	fog_material.set_shader_parameter("fog_density", fog_density)
	update_viewport_size()

func _process(_delta):
	
	var mouse_pos = get_viewport().get_mouse_position()
	fog_material.set_shader_parameter("mouse_position", mouse_pos )
	
	update_viewport_size()


func update_viewport_size():
	fog_material.set_shader_parameter("viewport_size", get_viewport().size)


