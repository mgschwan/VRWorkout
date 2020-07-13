extends Spatial

var spectrum_bar = preload("res://scenes/SpectrumBar.tscn").instance()
export var bars = 10
export var binsize = 200 #Hz
export var bar_elements = 10
export var min_db = 60

var nodes = []

var spectrum
var audio_bus

var avg_spectrum = 0


var elapsed = 0

func _process(delta):
	var new_avg = 0
	var multiplier = 1.0
	elapsed += delta
	if elapsed > 0.1:
		#Find a multiplier to rescale the spectrum for a nice visual experience
		if avg_spectrum > 0:
			multiplier = 0.5/avg_spectrum
			
			
		for i in range(bars):
			var energy = spectrum.get_magnitude_for_frequency_range(i*binsize, (i+1)*binsize, 0)
			var tmp = energy.length()
			new_avg += tmp
			var val = clamp(multiplier*tmp,0,1)
			
			nodes[i].set_energy(val)
			
		avg_spectrum = 0.9*avg_spectrum + 0.1*(new_avg/float(bars))
		elapsed = 0

func _ready():
	setup()
		
func setup():
	# create a specrum analyzer
	audio_bus = AudioServer.get_bus_index("Music") 
	AudioServer.add_bus_effect(audio_bus, AudioEffectSpectrumAnalyzer.new(), 0);
	spectrum = AudioServer.get_bus_effect_instance(audio_bus,0)
	
	for i in range(bars):
		var b = spectrum_bar.duplicate()
		nodes.append(b)
		add_child(b)
		b.translation.x = i*2.5
