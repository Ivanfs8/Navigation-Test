extends KinematicBody

export (NodePath) onready var nav = get_node(nav)

#func _ready():
	#nav.add_cached_collision_shape(get_node("StaticBody/CollisionShape") as CollisionShape)

func _physics_process(_delta):
	#translate(Vector3(-5 * delta, 0, 0))
	var __ = move_and_slide(Vector3(-5, 0, 0))
