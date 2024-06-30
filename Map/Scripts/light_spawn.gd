extends OmniLight3D


var spectrum
var volume
func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)

func _process(delta):
	volume = spectrum.get_magnitude_for_frequency_range(0, 10000).length()
	self.omni_range = volume * 500
	#self.light_energy = volume * 50
