extends KinematicBody


const GRAVITY = 9.8
const ACCELERATION = 0.5
const FRICTION = 0.1
const AIR_DRAG = 0.02
const MOUSE_SENSITIVITY = 0.1
const JUMP_DECEL = 0.1
const MIN_JUMP = 0.2

var vel = Vector3.ZERO
var speed = 10
var jump = 10


func _ready():
	# Capture the mouse when game starts.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	# Here we collect a vector representing the input.
	# This will later determine movement direction.
	var input_dir = Vector2.ZERO
	
	# Default Godot input maps are used here.
	# I recommend changing this to their own inputs later.
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	
	# Once input is collected we modify the velocity accordingly.
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized() * speed
		input_dir = input_dir.rotated(-rotation.y)
		
		if is_on_floor():
			vel = lerp(vel, Vector3(input_dir.x, vel.y, input_dir.y), ACCELERATION)
		else:
			vel = lerp(vel, Vector3(input_dir.x, vel.y, input_dir.y), AIR_DRAG)
	else:
		if is_on_floor():
			vel = lerp(vel, Vector3(0, vel.y, 0), FRICTION)
		else:
			vel = lerp(vel, Vector3(0, vel.y, 0), AIR_DRAG)

func _input(event):
	# Here we rotate both the camera and character based on mouse motion.
	if event is InputEventMouseMotion:
		$Camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = $Camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		$Camera.rotation_degrees = camera_rot
	
	# Some handy binds for testing.
	if event.is_action_pressed("ui_focus_next"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	# First we do the input gathering
	get_input()
	
	# Then we apply gravity and move accordingly.
	# The default values here should work for most things,
	# but you may want to adjust max floor angle.
	vel.y -= GRAVITY * delta
	vel = move_and_slide(vel, Vector3.UP, true, 4, 0.1 * TAU, true)
	
	# Jump.
	if Input.is_action_just_pressed("ui_select"):
		if is_on_floor():
			vel.y = jump
	
	# This is for variable jump,
	# slowing the character's vertical movement if the jump button is no longer held.
	if !Input.is_action_pressed("ui_select"):
		if vel.y > MIN_JUMP * jump:
			vel.y = lerp(vel.y, MIN_JUMP * jump, JUMP_DECEL)
