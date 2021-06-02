extends Spatial


var active = false

var target_control

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
	self.translation = cam.transform.xform(Vector3(0,0,-0.4))
	self.force_update_transform()
	self.rotate_object_local(Vector3(1,0,0), -PI/2)
	self.show()
	$StaticBody/CollisionShape.disabled = false
	active = true


func attach_keyboard(control, default_text = ""):
	open()
	target_control = control
	$Viewport/CanvasLayer/VirtualKeyboard.set_text(default_text)

func toggle():
	if active:
		close()
	else:
		open()


func _on_VirtualKeyboard_enter_pressed():
	if "text" in target_control:
		target_control.text = $Viewport/CanvasLayer/VirtualKeyboard.get_text()
		target_control.emit_signal("text_entered", target_control.text)
	close()


func _on_VirtualKeyboard_cancel_pressed():
	close()
