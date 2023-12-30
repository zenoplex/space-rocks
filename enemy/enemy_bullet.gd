class_name EnemyBullet
extends Area2D

var speed := 1000
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

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
