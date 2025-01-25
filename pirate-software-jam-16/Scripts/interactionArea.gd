extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player.isPossessing == true:
		#Moves the player along with the thrown weapon
		var tween = get_tree().create_tween()
		tween.tween_property(Global.player, "position", (global_position + Vector2(150,0)), 0.4)
func _on_body_entered(body: Node2D) -> void:
	SignalBus.can_possess.emit($".") #Connects to player.gd and weapon.gd

func _on_body_exited(body: Node2D) -> void:
	SignalBus.cannot_possess.emit($".") #Connects to player.gd and weapon.gd
