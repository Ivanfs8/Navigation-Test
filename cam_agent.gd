extends Camera

const ray_length := 1000

export (NodePath) onready var agent = get_node(agent)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from := project_ray_origin(event.position)
		var to := from + project_ray_normal(event.position) * ray_length
		var space_state := get_world().direct_space_state
		var result := space_state.intersect_ray(from, to, [], 1)
		if result:
			agent.move_to(result.position)
