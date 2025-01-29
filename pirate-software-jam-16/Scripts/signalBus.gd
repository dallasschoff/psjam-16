extends Node

signal start_game
signal change_level(level)
signal transition_finished

#Emitted by player, connected in weapon
signal possessed
signal vacated

#Emitted by interactionArea, connected to player
signal can_possess
