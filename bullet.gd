extends CharacterBody3D

const speed = 100

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -speed) * delta
