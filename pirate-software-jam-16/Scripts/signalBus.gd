extends Node

signal change_level(level)

#Emitted by interaction areas, connected in player and weapon
signal can_possess(area)
signal cannot_possess(area)
#Emitted by player, connected in weapon
signal possessed
signal vacated
