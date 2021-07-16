extends Node
class_name NavigationManager

export var max_nodes: int = 50
export var update_timer: float = 0.5

var pathfinding_active: bool = false
var thread_active: bool = false

var registered_nodes: Array = []
var tasks: Array = []
var current_time: float = 0.0

var pathfinder_thread: Thread = Thread.new()
var mutex: Mutex = Mutex.new()
var semaphore: Semaphore = Semaphore.new()

func _physics_process(delta):
	if thread_active || !pathfinding_active: return
	
	if current_time >= update_timer:
		#pathfinder_thread.start(self, "_async_pathfinder", registered_nodes.duplicate(), 0)
		for i in tasks.size():
			tasks[i] = {
				"from": registered_nodes[i].global_transform.origin,
				"to": registered_nodes[i].follow.global_transform.origin,
				"nav": registered_nodes[i].nav
				}
		if semaphore.post() != OK: print("err")
		current_time = 0.0
	else:
		current_time += delta

func _exit_tree(): stop_thread()

func register(node: Spatial) -> bool:
	if registered_nodes.size() < max_nodes:
		if node.get("follow") != null && node.get("nav") != null:
			registered_nodes.append(node)
			tasks.resize(registered_nodes.size())
			
			if pathfinding_active == false:
				pathfinding_active = true
				if pathfinder_thread.start(self, "_async_pathfinder", null, 0) != OK: print("err")
			return true
	return false

func unregister(node: Spatial) -> void:
	var i: int = registered_nodes.find(node)
	if i == -1: return
	
	registered_nodes.remove(i)
	tasks.remove(i)
	
	if registered_nodes.empty():
		current_time = 0.0
		stop_thread()
		return

func stop_thread() -> void:
	if pathfinder_thread.is_active():
		pathfinding_active = false
		if semaphore.post() != OK: print("err")
		pathfinder_thread.wait_to_finish()

func _async_pathfinder(data) -> void:
	while true:
		if semaphore.wait() != OK: print("err")
		
		mutex.lock()
		if !pathfinding_active: 
			mutex.unlock()
			return
		thread_active = true
		data = tasks.duplicate()
		mutex.unlock()
		
		var results: Array = []
		for task in data:
			mutex.lock()
			if !pathfinding_active: return
			var path: PoolVector3Array = task.nav.find_path(task.from, task.to)["points"]
			mutex.unlock()
			
			if path.size() == 0:
				path = [task.from, task.from]
			
			results.append(path)
		call_deferred("_tasks_completed", results)
		
		mutex.lock()
		thread_active = false
		if !pathfinding_active: 
			mutex.unlock()
			return
		mutex.unlock()

func _tasks_completed(results: Array):
	for i in registered_nodes.size():
		_send_result(registered_nodes[i], results[i])

func _send_result(node: Node, path: PoolVector3Array):
	node.call_deferred("update_path", path)
