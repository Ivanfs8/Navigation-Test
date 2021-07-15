extends KinematicBody

export var move_dir_speed = Vector3()

var velocity: Vector3 = Vector3()

func _physics_process(_delta):
	#translate(Vector3(-5 * delta, 0, 0))
	velocity = move_and_slide(move_dir_speed)
