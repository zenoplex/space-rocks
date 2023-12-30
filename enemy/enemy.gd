class_name Enemy
extends Area2D

@onready var gunCooldownTimer: Timer = get_node("GunCooldownTimer")
@onready var explostion: Explosion = get_node("Explosion")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gunCooldownTimer.one_shot = true
	gunCooldownTimer.wait_time = 1.5
	gunCooldownTimer.autostart = true


