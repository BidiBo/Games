class_name Jugador extends CharacterBody2D

@onready var sprtie_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_componentes: Health_Componentes = $Componentes/Health_Componentes


signal attack_finish
var move_speed := 100
var attack_damage := 50
var is_attack := false
var is_dead := false # Nueva variable para controlar el estado de muerte

func _ready():
	health_componentes.death.connect(on_death)
	
func _input(event: InputEvent) -> void:
	if not is_dead and event is InputEventMouseButton: # El jugador no puede atacar si está muerto
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Ataque()

func _physics_process(delta: float) -> void:
	if not is_attack and not is_dead: # El jugador no puede moverse si está muerto
		var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if move_direction:
			velocity = move_direction * move_speed
			sprtie_animation.play("Correr")
			if move_direction.x != 0:
				sprtie_animation.flip_h = move_direction.x < 0
			$AreaAtaque.scale.x = -1 if move_direction.x < 0 else 1
				
		else:
			velocity = velocity.move_toward(Vector2.ZERO, move_speed)
			sprtie_animation.play("Reposo")
		
		move_and_slide()

func Ataque():
	sprtie_animation.play("Ataque")
	is_attack = true

# Método que se ejecuta cuando la salud llega a cero
func on_death():
	print("game over")
	get_tree().paused
#	if not is_dead: # Asegurarse de que la lógica de muerte solo se ejecute una vez
#		is_dead = true
#		sprtie_animation.play("Muerte")
#		set_process(false) # Desactiva el procesamiento para detener el movimiento
#		set_physics_process(false) # Desactiva la física del jugador si es necesario

# Manejo de animaciones terminadas
func _on_animated_sprite_2d_animation_finished() -> void:
	if sprtie_animation.animation == "Ataque":
		is_attack = false
		attack_finish.emit()
	elif sprtie_animation.animation == "Muerte" and is_dead:
		queue_free() # Elimina al jugador después de completar la animación de muerte
		get_tree().paused = true

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if not is_dead and body is enemigo:
		body.in_attack_player_range = true

func _on_area_ataque_body_exited(body: Node2D) -> void:
	if not is_dead and body is enemigo:
		body.in_attack_player_range = false
