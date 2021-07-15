extends KinematicBody
class_name Agent

export (NodePath) onready var nav = get_node(nav)
export (NodePath) onready var debug_path = get_node(debug_path) as ImmediateGeometry

export var speed_max := 450.0
export var acceleration_max := 50.0
export var angular_speed_max := 240
export var angular_acceleration_max := 40

onready var acceleration := GSAITargetAcceleration.new()

onready var agent := GSAIKinematicBody3DAgent.new(self)

onready var path: GSAIPath = GSAIPath.new([global_transform.origin, global_transform.origin], true)
onready var follow_path = GSAIFollowPath.new(agent, path)

var valid: bool = false

func _ready():
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	agent.angular_speed_max = deg2rad(angular_speed_max)
	agent.angular_acceleration_max = deg2rad(angular_acceleration_max)
	agent.bounding_radius = 0.8
	
	follow_path.deceleration_radius = 1
	follow_path.arrival_tolerance = 10
	follow_path.prediction_time = 0.3
	follow_path.path_offset = 0
	
func _physics_process(delta: float):
	if !valid: return
	follow_path.calculate_steering(acceleration)
	
	agent.movement_type = agent.MovementType.POSITION
	agent._apply_steering(acceleration, delta)

func move_to(target: Vector3):
	var dict: Dictionary = nav.find_path(global_transform.origin, target)
	
	debug_path.clear()
	debug_path.begin(Mesh.PRIMITIVE_LINES)
	for p in dict["points"]:
		debug_path.add_vertex(p)
	debug_path.end()
	
	path.create_path(dict["points"])
	valid = true
