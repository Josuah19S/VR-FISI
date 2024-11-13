extends Node3D

var interface: XRInterface

func _ready():
	interface = XRServer.find_interface("OpenXR") # "OpenXR" for desktop, "Native mobile" for mobile
	if interface:
		print("Interface found")
		if interface and interface.initialize():
			get_viewport().use_xr = true
			print("XR interface initialized successfully")
		else:
			print("XR interface not initialized")
	else:
		print("No XR interface found")
