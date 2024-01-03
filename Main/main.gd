extends Node
@export var rock_scene: PackedScene
@export var enemy_scene: PackedScene

var level := 0
var score := 0
var playing := false
@onready var player: Player = get_node('Player')
@onready var hud: HUD = get_node('HUD')
@onready var rockSpawn: PathFollow2D = $RockPath/RockSpawn
@onready var enemySpawnTimer: Timer = $EnemySpawnTimer
@onready var level_up_sound: AudioStreamPlayer = get_node("LevelUpSound")
@onready var music: AudioStreamPlayer = get_node("Music")

# Type annotation is required for for loops
const offsets: Array[int] = [-1 ,1]
var screensize := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	# To enable input while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	enemySpawnTimer.one_shot = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()

func new_game() -> void:
	# Clear any rocks that are still in the scene
	get_tree().call_group("rocks", "queue_free")
	level = 0
	score = 0
	hud.update_score(score)
	hud.show_message_and_start_timer("Get Ready!")
	player.reset()
	# HUD show_message starts timer but it's not obvious from the code
	# Maybe should emit a signal instead
	await hud.get_node('Timer').timeout
	playing = true
	music.play()

func new_level() -> void:
	level += 1
	hud.show_message_and_start_timer("Wave %s" % level)
	for i in level:
		spawn_rock(getRockSpawnPosition(), getRockSpawnVelocity(), 3)
	enemySpawnTimer.wait_time = randf_range(5, 10)
	enemySpawnTimer.start()

func game_over() -> void:
	playing = false
	hud.game_over()
	music.stop()

func spawn_rock(position: Vector2, velocity: Vector2, size: int) -> void:
	var node := rock_scene.instantiate() as Rock
	node.screensize = screensize
	call_deferred("add_child", node)
	node.exploded.connect(self._on_rock_exploded)
	# Cannot call node.start because Rock as onready reference which will be null without path search
	node.call_deferred("start", position, velocity, size)

## get rock initial position
func getRockSpawnPosition() -> Vector2:
	rockSpawn.progress = randi()
	return rockSpawn.position

## get rock initial velocity
func getRockSpawnVelocity() -> Vector2:
	return Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)	

func _on_rock_exploded(size: int, radius: int, position: Vector2, linear_velocity: Vector2) -> void:
	if size < 2:
		return
	
	for offset in offsets:
		var direction: Vector2 = player.position.direction_to(position).orthogonal() * offset
		var new_position := position + direction * radius
		var new_velocity := direction * linear_velocity.length() * 1.1
		spawn_rock(new_position, new_velocity, size - 1)
	
## Connected with hud's start_game signal
func _on_hud_start_game() -> void:
	new_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not playing:
			return

		var scene_tree := get_tree()
		# Toggle paused state
		var is_paused := not scene_tree.paused
		scene_tree.paused = is_paused
		match is_paused:
			true:
				hud.update_message("Paused")
			false:
				hud.reset_message()

func _on_enemy_spawn_timer_timeout() -> void:
	var node: Enemy = enemy_scene.instantiate()
	add_child(node)
	node.target = player
	enemySpawnTimer.start(randf_range(20, 40))

func _on_player_lives_changed(lives: int) -> void:
	hud.update_lives(lives)
	
func _on_player_shield_changed(value: float) -> void:
	hud.update_shield(value)		
	