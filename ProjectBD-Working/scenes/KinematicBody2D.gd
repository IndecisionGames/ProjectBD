extends KinematicBody2D





onready var chatWindow = get_node("/root/Lobby/ChatBox")

export (int) var speed = 0
export (int) var acceleration = 10
export (int) var decceleration = 100
export (int) var maxSpeed = 200
var velocity = Vector2()
var isMoving = false

func get_input():
	if chatWindow.inputField.has_focus():
		velocity = Vector2()

	else:
		velocity = Vector2()
		if Input.is_action_pressed('ui_right'):
			isMoving = true
			velocity.x += 1
		if Input.is_action_pressed('ui_left'):
			isMoving = true
			velocity.x -= 1
		if Input.is_action_pressed('ui_up'):
			isMoving = true
			velocity.y -= 1
		if Input.is_action_pressed('ui_down'):
			isMoving = true
			velocity.y += 1
			
	if isMoving:
		speed += acceleration
	else:
		speed -= decceleration

	if speed >= maxSpeed:
		speed = maxSpeed
	if speed <= 0:
		speed = 0

	velocity = velocity.normalized() * abs(speed)
	print(speed)
	print(isMoving)
	print(velocity)

	isMoving = false

func _physics_process(delta):
	get_input()
	move_and_slide(velocity)
