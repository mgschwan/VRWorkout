extends ARVRController


func _physics_process(delta):
	self.global_transform.basis = Quat.IDENTITY
