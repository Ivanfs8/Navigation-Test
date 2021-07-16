extends KinematicBody
class_name Agent

export (NodePath) onready var nav = get_node(nav)
export (NodePath) onready var follow = get_node(follow) as Spatial if follow != null else null
export (NodePath) onready var nav_m = get_node(nav_m) as NavigationManager
export (NodePath) onready var debug_path = get_node(debug_path) as ImmediateGeometry if debug_path != null else null

export var move_speed: float = 15
export var rot_speed: float = 280

onready var tween_rot: TweenRotation = $TweenRotation

var path: PoolVector3Array
var path_ind: int

var velocity: Vector3 = Vector3()

func _ready():
	nav_m.register(self)

func _physics_process(_delta: float) -> void:
	if path_ind < path.size():
		var current_point: Vector3 = path[path_ind]
		var move_vec: Vector3 = (path[path_ind] - global_transform.origin).normalized()
		
		velocity = move_and_slide(move_vec * move_speed + $AvoidCollision.acceleration, Vector3.UP)
		
		if global_transform.origin.distance_to(current_point) < 0.2:
			path_ind += 1
			if path_ind < path.size(): 
				tween_rot.tween_look_at_deg(get_node("Mesh"), path[path_ind], rot_speed)

func move_to(target: Vector3) -> void:
	var mutex: Mutex = Mutex.new()
	mutex.lock()
	path = nav.find_path(global_transform.origin, target)["points"]
	mutex.unlock()
	path_ind = 0
	
	if 1 < path.size():
		tween_rot.tween_look_at_deg(get_node("Mesh"), path[1], rot_speed)
	
	update_debug_path()

func update_path(new_path: PoolVector3Array):
	path = new_path
	path_ind = 1
	
	if 1 < path.size(): tween_rot.tween_look_at_deg(get_node("Mesh"), path[1], rot_speed)
	
	update_debug_path()

func update_debug_path() -> void:
	if debug_path == null: return
	debug_path.clear()
	debug_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in path:
		debug_path.add_vertex(p)
	debug_path.end()
