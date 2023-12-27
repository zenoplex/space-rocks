class_name Explosion
extends Node2D

@onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	visible = false

func play() -> void:
	visible = true
	animationPlayer.play("explosion")
	await animationPlayer.animation_finished
	visible = false
