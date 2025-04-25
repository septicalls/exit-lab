extends Node3D

@onready var hit_rect: ColorRect = $UI/HitRect
@onready var spawns: Node3D = $Spawns
@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D

var enemy = load("res://enemy/enemy.tscn")
var enemy_instance

func _ready() -> void:
	randomize()
	hit_rect.visible = false

func _on_controller_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	enemy_instance = enemy.instantiate()
	enemy_instance.position = spawn_point
	enemy_instance.proto_controller = $Controller
	navigation_region_3d.add_child(enemy_instance)
	print("Spawned")
	
