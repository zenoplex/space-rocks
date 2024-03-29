class_name Enemy
extends Area2D

@export var bullet_scene: PackedScene
var bullet_spread := 0.2
var speed := 150
var rotation_speed := 120
var health := 3
var followPath := PathFollow2D.new()
# GDscript doeesn't support union types yet
var target: Player = null
var damage := 50

@onready var gunCooldownTimer: Timer = get_node("GunCooldownTimer")
@onready var explostion: Explosion = get_node("Explosion")
@onready var sprite2D: Sprite2D = get_node("Sprite2D")
@onready var enemyPaths: EnemyPaths = get_node("EnemyPaths")
@onready var animationPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var collisionShape2D: CollisionShape2D = get_node("CollisionShape2D")
@onready var laser_sound: AudioStreamPlayer = get_node("LaserSound")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gunCooldownTimer.one_shot = true
	gunCooldownTimer.wait_time = 1.5
	gunCooldownTimer.start()
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
	if randf() < 0.2:
		shoot_pulse(3, 0.3)
	else:
		shoot()
	
	gunCooldownTimer.start()

func shoot() -> void:
	if not target:
		return

	var direction := global_position.direction_to(target.global_position)
	var rotated_direction := direction.rotated(randf_range(-bullet_spread, bullet_spread))
	var node: EnemyBullet = bullet_scene.instantiate()
	get_tree().root.add_child(node)
	node.start(position, rotated_direction)
	laser_sound.play()

func shoot_pulse(shots: int, delay: float)-> void:
	for i in shots:
		shoot()
		var timer := get_tree().create_timer(delay)
		await timer.timeout

func take_damage(value: int) -> void:
	health -= value
	animationPlayer.play("flash")
	if health < 1:
		explode()
	
func explode() -> void:
	speed = 0
	sprite2D.hide()
	gunCooldownTimer.stop()
	collisionShape2D.set_deferred("disabled", true)
	await explostion.play()
	queue_free()

func _on_body_entered(body:Node2D) -> void:
	if body is Rock:
		return
	if body is Player:
		var player := body as Player
		player.shield -= damage
	take_damage(1)
		