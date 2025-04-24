extends CharacterBody3D

@onready var head: Node3D = $head
@onready var headbob: AnimationPlayer = $headbob

var current_speed = 5.0

@export var walking_speed = 4.0
const sprinting_speed = 8.0
const crouching_speed = 2.0
const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.15
const crouching_depth = -0.5
var lerp_speed = 10.0

var direction = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad( -event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-79),deg_to_rad(89))
		
		
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed 
		head.position.y =  lerp(head.position.y, 1.8 + crouching_depth , lerp_speed*delta)
	else:
		head.position.y =  lerp(head.position.y, 1.8 , lerp_speed*delta)
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
			headbob.speed_scale = 1.5
		else:
			current_speed = walking_speed
			headbob.speed_scale = 1.0
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)). normalized(),lerp_speed*delta)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if velocity.length() > 0.1:
			headbob.play("headbob_walk")
		else:
			headbob.pause()
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
