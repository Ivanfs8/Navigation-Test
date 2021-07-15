extends KinematicBody

export (NodePath) onready var nav = get_node(nav)

var velocity: Vector3 = Vector3()
#func _ready():
	#nav.add_cached_collision_shape(get_node("StaticBody/CollisionShape") as CollisionShape)

func _physics_process(_delta):
	#translate(Vector3(-5 * delta, 0, 0))
	velocity = move_and_slide(Vector3(-5, 0, 0))
