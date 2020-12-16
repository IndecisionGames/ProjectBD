extends KinematicBody2D

const MOVE_SPEED = 150

# Networking
var player_id
var control = true

func _ready():
	yield(get_tree(), "idle_frame")
	
func _physics_process(delta):
	if control == true:
		var look_vec = get_global_mouse_position() - global_position
		global_rotation = atan2(look_vec.y, look_vec.x)
		
		move(delta)
	
func move(delta):
	var move_vec = Vector2()
	
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
		
	move_vec = move_vec.normalized() * MOVE_SPEED
	move_and_slide(move_vec) # this already takes the delta into account
	
	rpc_unreliable("n_move", get_position(), global_rotation, player_id)
	
remote func n_move(pos, rot, pid):
	var root = get_parent()
	var pnode = root.get_node(str(pid))
	
	pnode.set_position(pos)
	pnode.set_global_rotation(rot)
