extends Camera3D

# Recoil and camera shake parameters
@export var recoil_strength: float = 0.05
@export var recoil_recovery_speed: float = 5.0
@export var horizontal_deviation: float = 0.05
@export var recoil_max: float = 1.0
@export var camera_shake_duration: float = 0.15

# ADS parameters
@export var normal_fov: float = 75.0
@export var ads_fov: float = 45.0  # Lower FOV when aiming for zoom effect
@export var ads_transition_speed: float = 10.0
@export var ads_position_offset := Vector3(0.0, 0.0, 0.1)  # Move weapon closer to camera when ADS
var is_aiming: bool = false
var target_fov: float

# Internal variables
var current_recoil: float = 0.0
var recoil_target: float = 0.0
var shake_time_remaining: float = 0.0
var original_rotation: Vector3
var shake_intensity: float = 0.0
var original_weapon_position: Vector3
var target_weapon_position: Vector3

func _ready():
	# Store the initial camera rotation
	original_rotation = rotation_degrees
	target_fov = normal_fov
	
	# Store original weapon position
	if get_node_or_null("ak47"):
		original_weapon_position = get_node("ak47").position
		target_weapon_position = original_weapon_position

func _process(delta):
	# Handle recoil recovery
	if current_recoil > 0:
		current_recoil = lerp(current_recoil, 0.0, recoil_recovery_speed * delta)
		
	# Apply camera rotation based on recoil
	rotation_degrees.x = original_rotation.x - current_recoil
	
	# Process camera shake if active
	if shake_time_remaining > 0:
		shake_time_remaining -= delta
		
		# Calculate shake intensity based on remaining time
		var shake_factor = shake_time_remaining / camera_shake_duration
		shake_intensity = recoil_strength * 0.2 * shake_factor
		
		# Apply random shake offset
		h_offset = randf_range(-shake_intensity, shake_intensity)
		v_offset = randf_range(-shake_intensity, shake_intensity)
		
		if shake_time_remaining <= 0:
			# Reset camera offsets when shake is complete
			h_offset = 0.0
			v_offset = 0.0
	
	# Smooth FOV transition for ADS
	fov = lerp(fov, target_fov, ads_transition_speed * delta)
	
	# Smooth weapon position transition for ADS
	if get_node_or_null("ak47"):
		var weapon = get_node("ak47")
		weapon.position = weapon.position.lerp(target_weapon_position, ads_transition_speed * delta)

# Call this when shooting
func shoot():
	# Calculate new recoil value (use reduced recoil when aiming)
	var recoil_modifier = 0.5 if is_aiming else 1.0
	var new_recoil = current_recoil + (recoil_strength * recoil_modifier)
	current_recoil = min(new_recoil, recoil_max)
	
	# Add random horizontal deviation to the gun (simulates horizontal recoil)
	if get_node_or_null("ak47"):
		var ak47 = get_node("ak47")
		var current_rotation = ak47.rotation_degrees
		# Less horizontal recoil when aimed
		var deviation_modifier = 0.3 if is_aiming else 1.0
		current_rotation.y += randf_range(-horizontal_deviation, horizontal_deviation) * 10 * deviation_modifier
		current_rotation.z += randf_range(-horizontal_deviation, horizontal_deviation) * 5 * deviation_modifier
		ak47.rotation_degrees = current_rotation
	
	# Start camera shake effect (reduced when aiming)
	shake_time_remaining = camera_shake_duration
	if is_aiming:
		shake_intensity *= 0.5

# Start aiming down sights
func start_ads():
	is_aiming = true
	target_fov = ads_fov
	
	# Move weapon closer to camera/center of screen
	if get_node_or_null("ak47"):
		target_weapon_position = original_weapon_position + ads_position_offset

# Stop aiming down sights
func stop_ads():
	is_aiming = false
	target_fov = normal_fov
	
	# Return weapon to original position
	if get_node_or_null("ak47"):
		target_weapon_position = original_weapon_position
