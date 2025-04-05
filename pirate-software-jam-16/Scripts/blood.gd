extends Node2D

@onready var particles1 = $CPUParticles2D
@onready var particles2 = $CPUParticles2D2

func _ready() -> void:
	pass # Replace with function body.
	
#func _process(_delta: float) -> void:
	#pass

func _on_timer_timeout() -> void:
	#Pause the particles to keep them on screen
	$CPUParticles2D.set_process(false)
	$CPUParticles2D.set_physics_process(false)
	$CPUParticles2D.set_process_input(false)
	$CPUParticles2D.set_process_internal(false)
	$CPUParticles2D.set_process_unhandled_input(false)
	$CPUParticles2D.set_process_unhandled_key_input(false)
	
	$CPUParticles2D2.set_process(false)
	$CPUParticles2D2.set_physics_process(false)
	$CPUParticles2D2.set_process_input(false)
	$CPUParticles2D2.set_process_internal(false)
	$CPUParticles2D2.set_process_unhandled_input(false)
	$CPUParticles2D2.set_process_unhandled_key_input(false)
