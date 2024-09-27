extends Node3D

var interface: XRInterface

func _ready():
	interface = XRServer.find_interface("Native mobile")
	if interface and interface.initialize():
		get_viewport().use_xr = true
		print("XR interface initialized successfully")
	else:
		print("XR interface not initialized")
