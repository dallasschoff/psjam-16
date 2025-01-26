extends Area2D

@onready var root = get_parent().get_parent()

#body is player, root is weapon
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body._can_possess(self)
		if root != null and body.interactionArea == self:
			root._can_be_possessed()

#body is player, root is weapon
func _on_body_exited(body: Node2D) -> void:
	if body is Player and root != null:
		body._cannot_possess()
		root._cannot_be_possessed()
