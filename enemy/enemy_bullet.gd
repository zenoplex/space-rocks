class_name EnemyBullet
extends Area2D

var speed := 600
var velocity := Vector2.ZERO
var damage := 15

func start(_position: Vector2, _direction: Vector2) -> void:
	position = _position
	rotation = _direction.angle()

func _process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	if _body is Player:
		_body.shield -= damage
	if _body is Rock:
		_body.explode()
	queue_free()
