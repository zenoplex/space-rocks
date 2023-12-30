class_name EnemyBullet
extends Area2D

var speed := 1000
var velocity := Vector2.ZERO

func start(_position: Vector2, _direction: Vector2) -> void:
	position = _position
	rotation = _direction.angle()

func _process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
