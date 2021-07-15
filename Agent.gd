extends Spatial
class_name Agent

export (NodePath) onready var nav = get_node(nav)
export (NodePath) onready var tween_rot = get_node(tween_rot) as TweenRotation
export var move_speed: float = 15
export var rot_speed: float = 280

var path: PoolVector3Array
var path_ind: int

onready var agent := GSAISteeringAgent.new()
#onready var follow_path := GSAIFollowPath.new(agent)
onready var priority := GSAIPriority.new(agent)

func move_to(target: Vector3):
	var dict: Dictionary = nav.find_path(global_transform.origin, target)
	path = dict["points"]
	path_ind = 0
	
	tween_rot.tween_look_at_deg(get_node("Mesh"), path[1], 135)

func _physics_process(delta: float):
	if path_ind < path.size():
		var current_point: Vector3 = path[path_ind]
		var move_vec: Vector3 = (path[path_ind] - global_transform.origin).normalized()
		
		var velocity: Vector3 = move_vec * delta * move_speed
		
		translate(velocity)
		
		if global_transform.origin.distance_to(current_point) < 0.2:
			path_ind += 1
			if path_ind < path.size(): 
				tween_rot.tween_look_at_deg(get_node("Mesh"), path[path_ind], rot_speed)
