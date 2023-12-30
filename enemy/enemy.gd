class_name Enemy
extends Area2D

@export var bullet_scene: PackedScene

var speed := 150
var rotation_speed := 120
var health := 3
var followPath := PathFollow2D.new()
# GDscript doeesn't support union types yet
var target: Player = null

@onready var gunCooldownTimer: Timer = get_node("GunCooldownTimer")
@onready var explostion: Explosion = get_node("Explosion")
@onready var sprite2D: Sprite2D = get_node("Sprite2D")
@onready var enemyPaths: EnemyPaths = get_node("EnemyPaths")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gunCooldownTimer.one_shot = true
	gunCooldownTimer.wait_time = 1.5
	gunCooldownTimer.autostart = true
	explostion.hide()
	sprite2D.frame = randi() % 3
	var path := enemyPaths.get_children()[randi() % enemyPaths.get_child_count()]

	if not path: 
		assert(false, "enemyPaths is empty")

	path.add_child(followPath)
	followPath.loop = false

func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed) * delta
	followPath.progress += speed * delta
	position = followPath.position
	if followPath.progress_ratio >= 1:
		queue_free()


func _on_gun_cooldown_timer_timeout() -> void:
	pass # Replace with function body.
