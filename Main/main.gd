extends Node
@export var rock_scene: PackedScene

var level := 0
var score := 0
var playing := false

# Type annotation is required for for loops
const offsets: Array[int] = [-1 ,1]
var screensize := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	
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
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	# HUD show_message starts timer but it's not obvious from the code
	# Maybe should emit a signal instead
	await $HUD/Timer.timeout
	playing = true

func new_level() -> void:
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(getRockSpawnPosition(), getRockSpawnVelocity(), 3)

func game_over() -> void:
	playing = false
	$HUD.game_over()

func spawn_rock(position: Vector2, velocity: Vector2, size: int) -> void:
	var node := rock_scene.instantiate()
	node.screensize = screensize
	node.start(position, velocity, size)
	call_deferred("add_child", node)
	node.exploded.connect(self._on_rock_exploded)

## get rock initial position
func getRockSpawnPosition() -> Vector2:
	$RockPath/RockSpawn.progress = randi()
	return $RockPath/RockSpawn.position

## get rock initial velocity
func getRockSpawnVelocity() -> Vector2:
	return Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)	

func _on_rock_exploded(size: int, radius: int, position: Vector2, linear_velocity: Vector2) -> void:
	if size < 2:
		return
	
	for offset in offsets:
		var direction: Vector2 = $Player.position.direction_to(position).orthogonal() * offset
		var new_position := position + direction * radius
		var new_velocity := direction * linear_velocity.length() * 1.1
		spawn_rock(new_position, new_velocity, size - 1)

## Connected with hud's start_game signal
func _on_hud_start_game() -> void:
	new_game()
		