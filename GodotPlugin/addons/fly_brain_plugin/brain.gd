extends Node

class_name Brain

var weights = {}
var neurons = {}
var aditional_neurons = {}
var sensory_neurons = {}

var thisState = 0
var nextState = 1
var fireThreshold = 50
var accumleft = 0
var accumright = 0
var stimulate_vision = [false, false]
var stimulate_olfactory = [false, false]
var stimulate_warm = [false, false]
var stimulate_cold = [false, false]
var stimulate_taste_external = [false, false]
var stimulate_taste_internal = [false, false]
var postSynaptic = {}

var synapses = {}

var muscleList = []
var mLeft = []
var mRight = []
var visual_neurons = {}
var olfactory_neurons = {}
var termo_warm_neurons = {}
var termo_cold_neurons = {}
var gustatory_external_neurons = {}
var gustatory_internal_neurons = {}
var sensory_neurons_total = []
var debug = false  # Ativar debug

func _init():
	var weights_module = preload("res://addons/fly_brain_plugin/weights.gd")
	var neurons_module = preload("res://addons/fly_brain_plugin/neurons.gd")
	var sensory_neurons_module = preload("res://addons/fly_brain_plugin/sensory_neurons.gd")
	var ascending_neurons_module = preload("res://addons/fly_brain_plugin/ascending_neurons.gd")
	var aditional_neurons_module = preload("res://addons/fly_brain_plugin/additional_neurons.gd")
	weights = weights_module.get_weights()
	neurons = neurons_module.get_full_neurons_list()
	aditional_neurons = aditional_neurons_module.get_additional_neurons()
	sensory_neurons = sensory_neurons_module.get_sensory_neurons()
	
func setup():
	if weights.size() == 0:
		print("Weights are empty. Please initialize weights.")
	
	for preSynaptic in weights.keys():
		synapses[preSynaptic] = func():
			dendrite_accumulate(preSynaptic)
	
	print ("Neuros: "+ str(neurons.size()))
	for neuron in neurons:
		postSynaptic[neuron] = [0, 0]
		
	visual_neurons = sensory_neurons['Visual']
	olfactory_neurons = sensory_neurons['Olfactory (Smell)']
	termo_warm_neurons = sensory_neurons['Thermo-Warm (Warm Temperature)']
	termo_cold_neurons = sensory_neurons['Thermo-Cold (Cold Temperature)']
	gustatory_external_neurons = sensory_neurons['Gustatory External (Taste External)']
	gustatory_internal_neurons = sensory_neurons['Gustatory Pharynx (Taste Internal)']
	
	sensory_neurons_total += olfactory_neurons['right'] + olfactory_neurons['left']
	sensory_neurons_total += termo_warm_neurons['right'] + termo_warm_neurons['left']
	sensory_neurons_total += termo_cold_neurons['right'] + termo_cold_neurons['left']
	sensory_neurons_total += gustatory_external_neurons['right'] + gustatory_external_neurons['left']
	sensory_neurons_total += gustatory_internal_neurons['right'] + gustatory_internal_neurons['left']
	
	mLeft = aditional_neurons['Descending Neurons to the Ventral Nerve Cord']['left']
	print ("mLeft: "+ str(mLeft.size()))
	mRight = aditional_neurons['Descending Neurons to the Ventral Nerve Cord']['right']
	print ("mRight: "+ str(mRight.size()))
	muscleList = mLeft + mRight
	print ("muscleList: "+ str(muscleList.size()))
	
func dendrite_accumulate(preSynaptic):
	if preSynaptic in weights:
		for postSynaptic in weights[preSynaptic]:
			if postSynaptic in self.postSynaptic:
				self.postSynaptic[postSynaptic][nextState] += weights[preSynaptic][postSynaptic]
				if debug:
					print("Accumulating for ", postSynaptic, " with weight ", weights[preSynaptic][postSynaptic], " total: ", self.postSynaptic[postSynaptic][nextState])
			else:
				if debug:
					print("PostSynaptic neuron ", postSynaptic, " not found in postSynaptic dictionary.")

func rand_excite():
	var synapses_keys = synapses.keys()
	var synapses_size = synapses_keys.size()
	if synapses_size > 0:
		for i in range(200):
			var random_key = synapses_keys[randi() % synapses_size]
			dendrite_accumulate(random_key)
			if debug:
				print("Exciting random key: ", random_key)


func update():
	if stimulate_vision[0]:
		for neuron in visual_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_vision[1]:
		for neuron in visual_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()

	if stimulate_olfactory[0]:
		for neuron in olfactory_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_olfactory[1]:
		for neuron in olfactory_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_warm[0]:
		for neuron in termo_warm_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_warm[1]:
		for neuron in termo_warm_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_taste_external[0]:
		for neuron in gustatory_external_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_taste_external[1]:
		for neuron in gustatory_external_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_taste_internal[0]:
		for neuron in gustatory_internal_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_taste_internal[1]:
		for neuron in gustatory_internal_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_cold[0]:
		for neuron in termo_cold_neurons['left']:
			dendrite_accumulate(neuron)
		run_synapses()
		
	if stimulate_cold[1]:
		for neuron in termo_cold_neurons['right']:
			dendrite_accumulate(neuron)
		run_synapses()


func run_synapses():
	if debug:
		print("Running synapses")
	for ps in postSynaptic:
		if ps not in muscleList and postSynaptic[ps][thisState] > fireThreshold:
			fire_neuron(ps)
			if debug:
				print("Firing neuron: ", ps)

	motor_control()

	for ps in postSynaptic:
		postSynaptic[ps][thisState] = postSynaptic[ps][nextState]

	var temp = thisState
	thisState = nextState
	nextState = temp

func fire_neuron(fneuron):
	dendrite_accumulate(fneuron)
	postSynaptic[fneuron][nextState] = 0
	if debug:
		print("Neuron ", fneuron, " fired and reset")

func motor_control():
	accumleft = 0
	accumright = 0

	for muscleName in muscleList:
		if muscleName in mLeft:
			accumleft += postSynaptic[muscleName][nextState] / 100
			postSynaptic[muscleName][nextState] = 0
		elif muscleName in mRight:
			accumright += postSynaptic[muscleName][nextState] / 100
			postSynaptic[muscleName][nextState] = 0

	if debug:
		print("Accumleft: ", accumleft, " Accumright: ", accumright)

func begins_with_any(string, prefixes):
	for prefix in prefixes:
		if string.begins_with(prefix):
			return true
	return false
