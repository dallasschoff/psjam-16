extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var emit_on_finish: bool = false

func _ready():
	$ColorRect.visible = false

func _fade(emit: bool):
	$ColorRect.visible = true
	emit_on_finish = emit
	animation_player.play("fade_to_black")

func _unfade():
	animation_player.play("fade_to_normal")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_black" and emit_on_finish:
		SignalBus.transition_finished.emit() #Connects to main menu
	if anim_name == "fade_to_normal":
		$ColorRect.visible = false
	emit_on_finish = false
