extends Spatial


var active = false

func _ready():
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	close()

func close():
	active = false
	self.hide()
	$StaticBody/CollisionShape.disabled = true
	
func open():
	var cam = get_viewport().get_camera()
	self.rotation = cam.rotation
	self.translation = cam.transform.xform(Vector3(0,0,-1))
	self.force_update_transform()
	self.rotate_object_local(Vector3(1,0,0), -PI/2)
	self.show()
	$StaticBody/CollisionShape.disabled = false
	active = true

func toggle():
	if active:
		close()
	else:
		open()
