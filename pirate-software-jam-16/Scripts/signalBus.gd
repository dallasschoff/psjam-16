extends Node

signal change_level(level)

#Emitted by interaction areas, connected in player and weapon
signal can_possess
signal cannot_possess
#Emitted by player, connected in weapon
signal possessed
signal vacated
