extends KinematicBody
class_name Agent

export (NodePath) onready var nav = get_node(nav)
export (NodePath) onready var debug_path = get_node(debug_path) as ImmediateGeometry if debug_path != null else null

export var move_speed: float = 15
export var rot_speed: float = 280

onready var tween_rot: TweenRotation = $TweenRotation

var path: PoolVector3Array
var path_ind: int

var velocity: Vector3 = Vector3()

func _physics_process(_delta: float) -> void:
	if path_ind < path.size():
		var current_point: Vector3 = path[path_ind]
		var move_vec: Vector3 = (path[path_ind] - global_transform.origin).normalized()
		
		#var velocity: Vector3 = move_vec * delta * move_speed
		
		velocity = move_and_slide(move_vec * move_speed + $AvoidCollision.acceleration, Vector3.UP)
		
		#translate(velocity)
		
		if global_transform.origin.distance_to(current_point) < 0.2:
			path_ind += 1
			if path_ind < path.size(): 
				tween_rot.tween_look_at_deg(get_node("Mesh"), path[path_ind], rot_speed)

func move_to(target: Vector3) -> void:
	var dict: Dictionary = nav.find_path(global_transform.origin, target)
	path = dict["points"]
	path_ind = 0
	
	if 1 < path.size():
		tween_rot.tween_look_at_deg(get_node("Mesh"), path[1], rot_speed)
	
	if debug_path == null: return
	debug_path.clear()
	debug_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in path:
		debug_path.add_vertex(p)
	debug_path.end()
