extends Area


func _physics_process(delta):
	self.global_transform.basis = Basis.IDENTITY
	#self.global_transform.origin = Vector3(0.5,0.5,0.5)

