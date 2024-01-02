class_name HUD
extends CanvasLayer

signal start_game

# TOOD: use get_node instead of $path
@onready var lives_counter: HBoxContainer = $MarginContainer/HBoxContainer/LivesCounter
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var start_button: TextureButton = $VBoxContainer/StartButton
@onready var shield_bar: TextureProgressBar = get_node("ShieldBar")

const bar_textures: Dictionary = {
	"green": preload("./bar_green_200.png"),
	"yellow": preload("./bar_yellow_200.png"),
	"red": preload("./bar_red_200.png")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()

func _on_timer_timeout() -> void:
	message_label.hide()
	message_label.text = ""

# TODO: method name is ambiguous since Timer starts at the same time
## Shows message and starts timer
func show_message(text: String) -> void:
	update_message(text)
	$Timer.start()

func update_message(text: String) -> void:
	message_label.text = text
	message_label.show()

func reset_message() -> void:
	message_label.text = ""
	message_label.hide()

func update_score(score: int) -> void:
	score_label.text = str(score)

func update_lives(lives: int) -> void:
	var children := lives_counter.get_children()
	# Can't get index of loop in for?
	# for child in children: will error since Node > int is an error
	for index in len(children):
		children[index].visible = index < lives

## Displays game over message and shows start button
func game_over() -> void:
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()
