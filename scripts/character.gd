extends CharacterBody3D

# Parámetros ajustables
var sensitivity := 0.0015 # Sensibilidad del ratón
var speed := 7.0          # Velocidad de movimiento
var jump_force := 7.0     # Fuerza de salto
var gravity := 20.0       # Gravedad
var is_jumping := false   # Estado del salto

@onready var cam = $XROrigin3D/XRCamera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Captura el mouse sin salir de la ventana

func _input(event):
	if event is InputEventMouseMotion:
		# Rotación horizontal (Y) - La cámara rota sobre el eje Y
		cam.rotate_y(-event.relative.x * sensitivity)
		# Rotación vertical (X) - La cámara rota sobre el eje X
		cam.rotation.x = clamp(cam.rotation.x - event.relative.y * sensitivity, -1.5, 1.5)

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Movimiento en XZ
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= cam.transform.basis.z
	if Input.is_action_pressed("move_backward"):
		dir += cam.transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= cam.transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += cam.transform.basis.x

	if dir != Vector3.ZERO:
		dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true

	# Mover el cuerpo teniendo en cuenta colisiones
	move_and_slide()
