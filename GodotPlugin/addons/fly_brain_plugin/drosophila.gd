extends Node2D

class_name WormNode

signal ate_food(food_area)
signal food_sense_neurons_stimulated(stimulated, left)
signal hunger_neurons_stimulated(stimulated)
signal nose_touching_neurons_stimulated(stimulated, left)
var BRAIN = Brain.new()

@export var limitingArea = Rect2(50, 50, 1000, 1000)
@export var time_scaling_factor = 1.0

@export var wormBrainDelay = 0.0

@export var head_texture : Texture2D = preload("res://addons/fly_brain_plugin/mosco.png")

@export var max_scale = 1.0 # The maximum scale of the worm's girth
@export var min_scale = 0.3 # The minimum scale of the worm's girth
@export var front_rate = 0.2 # Rate of girth increase at the front
@export var back_rate = 0.4 # Rate of girth decrease at the back

var time_since_eaten = 0
var head
var facingDir = 0.0
var targetDir = 0.0
var speed = 0.0
var targetSpeed = 0.0
var speedChangeInterval = 0.0
var food = []
var debug = false  # Ativar debug
var head_area
var sense_area
var target = Vector2()
var wormBrainLastUpdate = 0.0


# Function to load worm segments

func _ready():
	# Assuming these variables are already defined
	# segment_count, segment_distance, head_texture, body_texture, tail_texture
	
	head = Sprite2D.new()
	head.texture = head_texture
	add_child(head)

	# Add Area2D to detect collisions on the worm's head
	var head_area_left = Area2D.new()
	var collision_shape_left = CollisionShape2D.new()
	collision_shape_left.shape = CircleShape2D.new()
	collision_shape_left.shape.radius = 20
	head_area_left.add_child(collision_shape_left)
	head.add_child(head_area_left)
	head_area_left.position.y -= 10
	head_area_left.add_to_group("sensor")
	
	var head_area_right = Area2D.new()
	var collision_shape_right = CollisionShape2D.new()
	collision_shape_right.shape = CircleShape2D.new()
	collision_shape_right.shape.radius = 20
	head_area_right.add_child(collision_shape_right)
	head.add_child(head_area_right)
	head_area_right.position.y += 10
	head_area_right.add_to_group("sensor")

	var sense_area_left = Area2D.new()
	var collision_sense_shape_left = CollisionShape2D.new()
	collision_sense_shape_left.shape = CircleShape2D.new()
	collision_sense_shape_left.shape.radius = 130
	sense_area_left.add_child(collision_sense_shape_left)
	head.add_child(sense_area_left)
	sense_area_left.position.y -= 50
	sense_area_left.add_to_group("sensor")
	
	var sense_area_right = Area2D.new()
	var collision_sense_shape_right = CollisionShape2D.new()
	collision_sense_shape_right.shape = CircleShape2D.new()
	collision_sense_shape_right.shape.radius = 130
	sense_area_right.add_child(collision_sense_shape_right)
	head.add_child(sense_area_right)
	sense_area_right.position.y += 50
	sense_area_right.add_to_group("sensor")

	head_area_left.connect("area_entered", Callable(self, "_on_head_area_entered_left"))
	head_area_left.connect("area_exited", Callable(self, "_on_head_area_exited_left"))
	head_area_right.connect("area_entered", Callable(self, "_on_head_area_entered_right"))
	head_area_right.connect("area_exited", Callable(self, "_on_head_area_exited_right"))

	sense_area_left.connect("area_entered", Callable(self, "_on_sense_area_entered_left"))
	sense_area_left.connect("area_exited", Callable(self, "_on_sense_area_exited_left"))
	sense_area_right.connect("area_entered", Callable(self, "_on_sense_area_entered_right"))
	sense_area_right.connect("area_exited", Callable(self, "_on_sense_area_exited_right"))

	BRAIN.setup()
	BRAIN.rand_excite()

	sensingFood(false, null, false)
	sensingFood(false, null, true)

	set_process(true)


func _process(delta):
	if wormBrainLastUpdate > wormBrainDelay:
		wormBrainLastUpdate = wormBrainDelay
		
	if wormBrainLastUpdate > 0:
		wormBrainLastUpdate -= delta
	else:
		wormBrainLastUpdate = wormBrainDelay
		BRAIN.update()	
		update_brain()
		update_simulation(delta)
		move()
		
func move():
	head.position = target

func update_brain():
	var scaling_factor = time_scaling_factor  # Aumentar o fator de escala
	var new_dir = (BRAIN.accumleft - BRAIN.accumright) / scaling_factor
	targetDir = facingDir + new_dir * PI
	targetSpeed = (abs(BRAIN.accumleft) + abs(BRAIN.accumright)) / (scaling_factor * 2)  # Ajustar a fórmula de velocidade
	speedChangeInterval = (targetSpeed - speed) / (scaling_factor * 1.5)
	
	if debug:
		print("Accumleft: ", BRAIN.accumleft, " Accumright: ", BRAIN.accumright)
		print("New Direction: ", new_dir, " Target Direction: ", targetDir)
		print("Target Speed: ", targetSpeed, " Speed Change Interval: ", speedChangeInterval)

func update_simulation(delta):
	speed += speedChangeInterval
	facingDir = lerp_angle(facingDir, targetDir, 0.1)
	var movement = Vector2(cos(facingDir), sin(facingDir)) * speed * delta
	target += movement
	head.rotation = facingDir
	
	# Manter a minhoca dentro da área limite
	var converted_target =head.global_position
	var diff = converted_target - head.position
	var converted_area = limitingArea
	converted_area.position -= diff
	var worm_is_coliding = false

	if target.x < converted_area.position.x:
		target.x = converted_area.position.x
		worm_is_coliding = true
	elif target.x > converted_area.position.x + converted_area.size.x:
		target.x = converted_area.position.x + converted_area.size.x
		worm_is_coliding = true
	
	if target.y < converted_area.position.y:
		target.y = converted_area.position.y
		worm_is_coliding = true
	elif target.y > converted_area.position.y + converted_area.size.y:
		target.y = converted_area.position.y + converted_area.size.y
		worm_is_coliding = true
		
	if debug:
		print("Facing Direction: ", facingDir, " Speed: ", speed)
		print("Movement: ", movement, " Target Position: ", target)

func _on_sense_area_entered_right(area):
	senseAreaEntered(area, false)

func _on_sense_area_exited_right(area):
	senseAreaExited(area, false)
	
func _on_sense_area_entered_left(area):
	senseAreaEntered(area, true)

func _on_sense_area_exited_left(area):
	senseAreaExited(area, true)
		
func senseAreaEntered(area, left):
	if area.is_in_group("fly_food"):
		sensingFood(true, area, left)
		
func senseAreaExited(area, left):
	if area.is_in_group("fly_food"):
		sensingFood(false, area, left)
	
func sensingFood(isSensing, area, left):
	BRAIN.stimulate_olfactory = [left, !left]
	emit_signal("food_sense_neurons_stimulated", isSensing, left)
