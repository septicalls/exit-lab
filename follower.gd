extends CharacterBody3D

var movement_speed: float = 2.0
var attack_range = 5
var current_animation = "rifle_walk/mixamo_com"
var last_played_animation: String = ""

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var proto_controller: CharacterBody3D
@onready var animation_player: AnimationPlayer = $idle/AnimationPlayer2

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	animation_player.get_animation(current_animation).loop = true
	animation_player.play(current_animation)
	
	navigation_agent.set_target_position(proto_controller.global_position)

func _physics_process(delta):
	velocity = Vector3.ZERO


	var look_target = proto_controller.global_position
	look_target.y = global_position.y
	look_at(look_target, Vector3.UP)
		
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.8)

	if global_position.distance_to(proto_controller.global_position) < attack_range:
		navigation_agent.set_target_position(global_position)
		current_animation = "firing_rifle/mixamo_com"
	else:
		navigation_agent.set_target_position(proto_controller.global_position)
		current_animation = "shoot_rifle/mixamo_com"

	if navigation_agent.is_navigation_finished() and current_animation == "firing_rifle/mixamo_com":
		velocity = Vector3.ZERO
	else:
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * movement_speed
	
	#proto_controller.hit()

	transition_animation()

	move_and_slide()
	
func transition_animation():
	if current_animation != last_played_animation:
		if animation_player.has_animation(current_animation):
			animation_player.get_animation(current_animation).loop = true
			animation_player.play(current_animation)
			last_played_animation = current_animation
