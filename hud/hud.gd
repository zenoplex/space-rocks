class_name HUD
extends CanvasLayer

signal start_game

@onready var lives_counter: HBoxContainer = get_node("MarginContainer/HBoxContainer/LivesCounter")
@onready var score_label: Label = get_node("MarginContainer/HBoxContainer/ScoreLabel")
@onready var message_label: Label = get_node("VBoxContainer/MessageLabel")
@onready var start_button: TextureButton = get_node("VBoxContainer/StartButton")
@onready var shield_bar: TextureProgressBar = get_node("MarginContainer/HBoxContainer/ShieldBar")

const bar_textures: Dictionary = {
	"green": preload("./bar_green_200.png"),
	"yellow": preload("./bar_yellow_200.png"),
	"red": preload("./bar_red_200.png")
}

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

func update_shield(value: float) -> void:
	shield_bar.value = value

	if value > 0.66:
		shield_bar.texture_progress = bar_textures["green"]
	elif value > 0.33:
		shield_bar.texture_progress = bar_textures["yellow"]
	else:
		shield_bar.texture_progress = bar_textures["red"]

## Displays game over message and shows start button
func game_over() -> void:
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()
