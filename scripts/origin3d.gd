extends XROrigin3D

var sensitivity := 0.005 # Mouse sensititvity
var speed := 3

@onready var cam = $XRCamera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Captura el mouse sin salir de la ventana

func _input(event):
	if event is InputEventMouseMotion:
		# Rotación horizontal (Y) - La cámara rota sobre el eje Y
		cam.rotate_y(-event.relative.x * sensitivity)
		# Rotación vertical (X) - La cámara rota sobre el eje X
		cam.rotation.x = clamp(cam.rotation.x - event.relative.y * sensitivity, -1.5, 1.5)

func _process(delta):
	var dir = Vector3.ZERO # direction
	
	# Determinar el movimiento
	if Input.is_action_pressed("ui_up"):
		dir -= cam.transform.basis.z
	if Input.is_action_pressed("ui_down"):
		dir += cam.transform.basis.z
	if Input.is_action_pressed("ui_left"):
		dir -= cam.transform.basis.x
	if Input.is_action_pressed("ui_right"):
		dir += cam.transform.basis.x
	
	# Normalizar la dirección para evitar un movimiento más rápido en diagonal
	if dir != Vector3.ZERO:
		dir = dir.normalized()
	
	translate(dir * speed * delta) # Aplicar el movimiento
