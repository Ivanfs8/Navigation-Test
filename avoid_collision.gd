extends Node

export (NodePath) onready var self_body = get_node(self_body) as PhysicsBody
export (NodePath) onready var proximity_area = get_node(proximity_area) as Area

export var linear_acceleration_max := 20.0

var proximity_bodies: Array = []

var acceleration: Vector3 = Vector3()

var _first_neighbor: PhysicsBody
var _shortest_time: float
var _first_minimum_separation: float
var _first_distance: float
var _first_relative_position: Vector3
var _first_relative_velocity: Vector3

func _ready() -> void:
	proximity_area.connect("body_entered", self, "_on_ProximityArea_body_entered")
	proximity_area.connect("body_exited", self, "_on_ProximityArea_body_exited")

func _calculate_acceleration():
	_shortest_time = INF
	_first_neighbor = null
	_first_minimum_separation = 0
	_first_distance = 0
	
	for body in proximity_bodies:
		_compare_body(body)
	
	if proximity_bodies.size() == 0 || _first_neighbor == null:
		acceleration = Vector3.ZERO
		return
	
	if (
		_first_minimum_separation <= 0
		or _first_distance < get_radius(self_body) + get_radius(_first_neighbor)
	):
		acceleration = _first_neighbor.global_transform.origin - self_body.global_transform.origin
	else:
		acceleration = (
			_first_relative_position
			+ (_first_relative_velocity * _shortest_time)
		)

	acceleration = (acceleration.normalized() * -linear_acceleration_max)

func _compare_body(other_body: PhysicsBody) -> bool:
	var relative_position: Vector3 = other_body.global_transform.origin - self_body.global_transform.origin
	
	var other_body_velocity: Vector3 = get_velocity(other_body)
	var self_body_velocity: Vector3 = get_velocity(self_body)
	
	var other_radius: float = get_radius(other_body)
	var self_radius: float = get_radius(self_body)
	
	var relative_velocity := other_body_velocity - self_body_velocity
	var relative_speed_squared := relative_velocity.length_squared()

	if relative_speed_squared == 0:
		return false
	else:
		var time_to_collision = -relative_position.dot(relative_velocity) / relative_speed_squared

		if time_to_collision <= 0 or time_to_collision >= _shortest_time:
			return false
		else:
			var distance = relative_position.length()
			var minimum_separation: float = (
				distance
				- sqrt(relative_speed_squared) * time_to_collision
			)
			if minimum_separation > self_radius + other_radius:
				return false
			else:
				_shortest_time = time_to_collision
				_first_neighbor = other_body
				_first_minimum_separation = minimum_separation
				_first_distance = distance
				_first_relative_position = relative_position
				_first_relative_velocity = relative_velocity
				return true

func get_velocity(body: PhysicsBody) -> Vector3:
	if body is KinematicBody:
		if body.get("velocity") != null:
			return body.velocity
		elif body.get("linear_velocity") != null:
			return body.linear_velocity
	elif body is RigidBody:
		return body.linear_velocity
	
	return Vector3.ZERO

func get_radius(body: PhysicsBody) -> float:
	var shape: Shape = body.shape_owner_get_shape(0,0)
	
	if shape.get("radius") != null:
		return shape.radius
	elif shape is BoxShape:
		return max(shape.extents.x, shape.extents.z)
	
	return 0.0

func _on_ProximityArea_body_entered(body: PhysicsBody) -> void:
	proximity_bodies.append(body)
	_calculate_acceleration()

func _on_ProximityArea_body_exited(body: PhysicsBody) -> void:
	proximity_bodies.erase(body)
	if proximity_bodies.size() == 0:
		acceleration = Vector3.ZERO
