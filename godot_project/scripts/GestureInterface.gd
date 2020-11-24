extends Spatial

signal attack
signal defense

#this defines the object the GestureInterface is attached to
var attached_to
var is_viewed = false
var target_rotation = 0

var visibility_box = null
onready var interface = $Interface

func _ready():
	visibility_box = get_node("VisibilityNotifier")
	set_as_toplevel(true)
	set_size (1.0)

func set_size(value):
	interface.translation.z = clamp (value,  0.4,  0.75 )
	interface.translation.z = clamp (value,  0.4,  0.75 )

func reset_rotation():
	if attached_to:
		self.rotation.y = 0
		
	
func attach(target):
	self.rotation.y = target.rotation.y + PI
	attached_to = target	
	
func _process(delta):
	if attached_to:
		self.global_transform.origin = attached_to.global_transform.origin
		if attached_to.translation.y < 0.6:
			self.global_transform.origin.y += abs(attached_to.translation.y - 0.6)	
		set_size(attached_to.translation.y/3.1)
		self.rotation.y = self.rotation.y*0.99 + target_rotation * 0.01

		
		#if not is_viewed:
		#	self.rotation.y = self.rotation.y*0.97 + attached_to.rotation.y * 0.03

func _on_VisibilityNotifier_camera_entered(camera):
	if camera == attached_to:
		is_viewed = true

func _on_VisibilityNotifier_camera_exited(camera):
	if camera == attached_to:
		is_viewed = false

func _on_Attack_activated():
	#reset_rotation()
	emit_signal("attack")
	
func _on_Defense_activated():
	#reset_rotation()
	emit_signal("defense")
