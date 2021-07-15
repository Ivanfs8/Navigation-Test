extends Node
class_name TweenRotation

export var only_y_axis: bool = false
export var time_total: float = 3
export (float, 0, 359) var deg_per_sec: float = 45
var time_current: float = 0

var rotate_node: Spatial
var target_pos: Vector3

var rot_start: Quat = Quat()
var rot_target: Quat = Quat()

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	var weight: float = clamp(time_current / time_total, 0, 1) if time_total > 0 else 1.0
	var lerped_quat: Quat = rot_start.slerp(rot_target, weight)
	var lerped_angle: float = lerp_angle(rot_start.get_euler().y, rot_target.get_euler().y, weight)
	
	time_current += delta
	
	if !only_y_axis:
		rotate_node.transform.basis = Basis(lerped_quat)
		if rotate_node.rotation == rot_target.get_euler():
			set_physics_process(false)
	else:
		rotate_node.rotation.y = lerped_angle
		if rotate_node.rotation.y == rot_target.get_euler().y:
			set_physics_process(false)

func tween_look_at(to_rotate: Spatial, target: Vector3, time: float):
	rotate_node = to_rotate
	target_pos = target
	time_current = 0
	time_total = time
	
	rot_start = to_rotate.global_transform.basis.get_rotation_quat()
	
	var rotated_transform: Transform = rotate_node.global_transform.looking_at(target_pos, Vector3.UP)
	rotated_transform = rotated_transform.rotated(Vector3.UP, deg2rad(180))
#	rotated_transform.basis = rotated_transform.basis.orthonormalized().rotated(Vector3.UP, deg2rad(180))
#	rotated_transform.inverse()
	rot_target = rotated_transform.basis.get_rotation_quat()
	
	if time <= 0:
		_physics_process(0)
	else:
		set_physics_process(true)

func tween_look_at_deg(to_rotate: Spatial, target: Vector3, deg: float):
	rotate_node = to_rotate
	target_pos = target
	time_current = 0
	deg_per_sec = deg
	
	rot_start = to_rotate.transform.basis.get_rotation_quat()
	var rotated_transform: Transform = rotate_node.global_transform.looking_at(target_pos, Vector3.UP)
	rotated_transform = rotated_transform.rotated(Vector3.UP, deg2rad(180))
	rot_target = Quat(rotated_transform.basis)
#	rotated_transform.basis.get_rotation_quat()
	
	var angleDiff = acos(
		rotate_node.transform.basis.z.dot(rotated_transform.basis.z)
	)
	time_total = angleDiff/deg2rad(deg_per_sec)
	
	set_physics_process(true)

func stop_tween():
	target_pos = Vector3()
	time_current = 0
	
	set_physics_process(false)
	
	if !only_y_axis:
		rotate_node.transform.basis = Basis(rot_target)
	else:
		rotate_node.rotation.y = rot_target.get_euler().y
