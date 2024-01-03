class_name Explosion
extends Node2D

@onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var explosion_sound: AudioStreamPlayer = get_node("ExplosionSound")

func _ready() -> void:
	visible = false

func play() -> void:
	visible = true
	animationPlayer.play("explosion")
	explosion_sound.play()
	await animationPlayer.animation_finished
	visible = false
