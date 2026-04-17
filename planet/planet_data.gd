@tool
class_name PlanetData
extends Resource

@export var radius: float = 1.0:
	set(val):
		radius = val
		emit_changed()
@export var resolution: int = 10:
	set(val):
		resolution = val
		emit_changed()
@export var planet_color: GradientTexture1D:
	set(val):
		planet_color = val
		if planet_color != null and not planet_color.changed.is_connected(emit_changed):
			planet_color.changed.connect(emit_changed)
@export var planet_noise: Array[PlanetNoise]:
	set(val):
		planet_noise = val
		emit_changed()
		for n: PlanetNoise in planet_noise:
			if n != null and not n.changed.is_connected(emit_changed):
				n.changed.connect(emit_changed)

var min_height: float = 99999.0
var max_height: float = 0.0


func point_on_planet(point_on_sphere: Vector3) -> Vector3:
	var elevation: float = 0.0
	var base_elevation: float = 0.0
	if planet_noise[0].noise_map != null:
		base_elevation = (planet_noise[0].noise_map.get_noise_3dv(point_on_sphere * 100.0))
		base_elevation = (base_elevation + 1) / 2.0 * planet_noise[0].amplitude
		base_elevation = max(0, base_elevation - planet_noise[0].min_height)
	for n: PlanetNoise in planet_noise:
		if n != null and n.noise_map != null:
			var mask:float = 1.0
			if n.use_first_layer_as_mask:
				mask = base_elevation
			var level_elevation: float = n.noise_map.get_noise_3dv(point_on_sphere * 100.0)
			level_elevation = (level_elevation + 1) / 2.0 * n.amplitude
			level_elevation = max(0.0, level_elevation - n.min_height) * mask
			elevation += level_elevation
	return point_on_sphere * radius * (elevation + 1.0)
	
