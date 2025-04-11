extends Area2D

@onready var root = get_parent().get_parent()

#body is player, root is weapon
func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.interaction_stack.find(self) == -1:
		body._add_to_interaction_stack(self)

#body is player, root is weapon
func _on_body_exited(body: Node2D) -> void:
	if body is Player and root != null:
		#In an effort to make possessing easier/forgiving,
		#if this is the last interaction area in the interaction stack for the player
		#provide a bit of time after leaving the interaction area's body to still possess
		if body.interaction_stack.size() == 1:
			await get_tree().create_timer(0.5).timeout
			if body.interactionArea == null:
				body._remove_from_interaction_stack(self)
		else:
			body._remove_from_interaction_stack(self)
