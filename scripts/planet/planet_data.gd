@tool
class_name PlanetData
extends Resource

@export var biomes: Array[PlanetBiome]:
	set(val):
		biomes = val
		emit_changed()
		for n: PlanetBiome in biomes:
			if n != null and not n.changed.is_connected(emit_changed):
				n.changed.connect(emit_changed)
@export var biome_amplitude: float:
	set(val):
		biome_amplitude = val
		emit_changed()
@export var biome_blend: float:
	set(val):
		biome_blend = clamp(val, 0.0, 1.0)
		emit_changed()
@export var biome_noise: FastNoiseLite:
	set(val):
		biome_noise = val
		emit_changed()
		if biome_noise != null and not biome_noise.changed.is_connected(emit_changed):
			biome_noise.changed.connect(emit_changed)
@export var biome_offset: float:
	set(val):
		biome_offset = val
		emit_changed()
@export var radius: float = 1.0:
	set(val):
		radius = val
		emit_changed()
@export var resolution: int = 10:
	set(val):
		resolution = val
		emit_changed()
@export var planet_noise: Array[PlanetNoise]:
	set(val):
		planet_noise = val
		emit_changed()
		for n: PlanetNoise in planet_noise:
			if n != null and not n.changed.is_connected(emit_changed):
				n.changed.connect(emit_changed)

var min_height: float = 99999.0
var max_height: float = 0.0


func biome_percent_from_point(point_on_unit_sphere: Vector3) -> float:
	# y in [-1,1] maps to latitude [0,1]: 0 = south pole, 1 = north pole
	var height_percent: float = (point_on_unit_sphere.y + 1.0) / 2.0
	height_percent += (
			((biome_noise.get_noise_3dv(point_on_unit_sphere * 100.0)
			+ 1.0 / 2.0) - biome_offset) * biome_amplitude
	)
	var biome_index: float = 0.0
	var num_biome: float = biomes.size()
	# +0.0001 prevents a zero-width blend range when biome_blend is 0
	var blend_range: float = biome_blend / 2.0 + 0.0001
	
	# Soft blend: accumulate weighted biome index so transitions aren't hard cuts
	for i: int in range(num_biome):
		if biomes[i] != null:
			var dst: float = height_percent - biomes[i].start_height
			var lerp_val: float = clamp(inverse_lerp(-blend_range, blend_range, dst), 0.0, 1.0)
			var weight: float = lerp_val
			biome_index *= (1 - weight)
			biome_index += i * weight
			#if biomes[i].start_height < height_percent:
				#biome_index = i
			#else:
				#break
		else:
			break
	
	# Normalize to [0,1] so it maps directly to UV.y on the biome texture
	return biome_index / max(1.0, num_biome - 1)


func point_on_planet(point_on_sphere: Vector3) -> Vector3:
	var elevation: float = 0.0
	# Layer 0 is the base layer — other layers can use it as a mask so detail
	# noise only appears where the base terrain already has height (e.g. no craters in oceans)
	var base_elevation: float = 0.0
	if planet_noise[0].noise_map != null:
		# Scale by 100 to sample the noise at a frequency that produces continent-scale features
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
	# +1.0 ensures the planet surface sits at least at radius even with zero elevation
	return point_on_sphere * radius * (elevation + 1.0)


func update_biome_texture() -> ImageTexture:
	# Builds a 2D texture where each row is one biome's color gradient.
	# The shader samples it with UV = (height_along_gradient, biome_index),
	# so row count = biome count and all gradients must share the same width.
	var image_texture: ImageTexture = ImageTexture.new()
	var dyn_image: Image = Image.new()

	var h: int = biomes.size()
	if h > 0:
		var data: PackedByteArray
		var w: int = biomes[0].gradient.width
		for b: PlanetBiome in biomes:
			data.append_array(b.gradient.get_image().get_data())
		dyn_image = Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
		
		image_texture = ImageTexture.create_from_image(dyn_image)
		image_texture.resource_name = "Biome Texture"
	else:
		image_texture = ImageTexture.create_from_image(dyn_image)
	
	return image_texture
