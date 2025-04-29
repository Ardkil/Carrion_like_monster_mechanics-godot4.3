extends GPUParticles2D

func _ready() -> void:
	emitting = true

func _process(delta: float) -> void:
	if !emitting:
		queue_free()
