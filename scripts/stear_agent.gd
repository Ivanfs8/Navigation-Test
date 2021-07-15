extends KinematicBody

export (NodePath) onready var nav = get_node(nav)
export (NodePath) onready var debug_path = get_node(debug_path) as ImmediateGeometry if debug_path != null else null

export var linear_speed_max := 60.0
export var linear_acceleration_max := 40.0
export var angular_speed_max := 280.0
export var angular_acceleration_max := 180.0
export var angular_drag_percentage := 0.5

export (float, 0, 10) var follow_arrival_tolerance := 1
export (float, 0, 50) var follow_deceleration_radius := 10
export (float, 0, 5, 0.1) var follow_predict_time := 0.3
export (float, 0, 200) var follow_path_offset := 20.0

export var look_alignment_tolerance := 5.0
export var look_deceleration_radius := 60.0

var _accel := GSAITargetAcceleration.new()
var _valid := false
var _drag := 0.1

onready var agent := GSAIKinematicBody3DAgent.new(self)
onready var path := GSAIPath.new([global_transform.origin, global_transform.origin], true)
onready var follow := GSAIFollowPath.new(agent, path, 0, 0)
onready var look := GSAILookWhereYouGo.new(agent)

onready var follow_look_blend := GSAIBlend.new(agent)

func _ready() -> void:
	agent.linear_acceleration_max = linear_acceleration_max
	agent.linear_speed_max = linear_speed_max
	agent.angular_speed_max = angular_speed_max
	agent.angular_acceleration_max = angular_acceleration_max
	
	agent.angular_drag_percentage = angular_drag_percentage
	#agent.apply_angular_drag = false
	
	agent.linear_drag_percentage = _drag
	
	follow.path_offset = follow_path_offset
	follow.prediction_time = follow_predict_time
	follow.deceleration_radius = follow_deceleration_radius
	follow.arrival_tolerance = follow_arrival_tolerance
	
	look.alignment_tolerance = deg2rad(look_alignment_tolerance)
	look.deceleration_radius = deg2rad(look_deceleration_radius)
	look.time_to_reach = 0.3
	
	follow_look_blend.add(follow, 1)
	follow_look_blend.add(look, 2)
	follow_look_blend.is_enabled = true

func _physics_process(delta: float) -> void:
	if _valid:
		follow_look_blend.calculate_steering(_accel)
		agent._apply_steering(_accel, delta)

func move_to(target: Vector3):
	var dict: Dictionary = nav.find_path(global_transform.origin, target)
	var positions: PoolVector3Array = dict["points"]
	
	path.create_path(positions)
	_valid = true
	
	if debug_path == null: return
	debug_path.clear()
	debug_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in positions:
		debug_path.add_vertex(p)
	debug_path.end()
