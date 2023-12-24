extends Area2D
@export var speed := 1000

var velocity := Vector2.ZERO

func _ready() -> void:
	start(transform)

func start(_transform: Transform2D) -> void:
	transform = _transform
	velocity = transform.x * speed

func _process(delta: float) -> void:
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
