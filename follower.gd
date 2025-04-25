extends CharacterBody3D

var movement_speed: float = 2.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var proto_controller: CharacterBody3D

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	navigation_agent.set_target_position(proto_controller.global_position)

func _physics_process(_delta):
	if navigation_agent.is_navigation_finished():
		print("Finished")
		
	navigation_agent.set_target_position(proto_controller.global_position)

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed

	move_and_slide()
