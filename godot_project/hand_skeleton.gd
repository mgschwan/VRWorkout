extends Spatial

signal body_entered(area)
signal body_exited(area)

var mesh

var hand : ARVRController = null;
var model : Spatial = null;
var skel : Skeleton = null; 

var beast_mode = false
var hand_confidence = 1.0

# this array is used to get the orientations from the sdk each frame (an array of Quat)
var _vrapi_bone_orientations = [];
var claws


enum ovrHandFingers {
	Thumb		= 0,
	Index		= 1,
	Middle		= 2,
	Ring		= 3,
	Pinky		= 4,
	Max,
	EnumSize = 0x7fffffff
};

enum ovrHandBone {
	Invalid						= -1,
	WristRoot 					= 0,	# root frame of the hand, where the wrist is located
	ForearmStub					= 1,	# frame for user's forearm
	Thumb0						= 2,	# thumb trapezium bone
	Thumb1						= 3,	# thumb metacarpal bone
	Thumb2						= 4,	# thumb proximal phalange bone
	Thumb3						= 5,	# thumb distal phalange bone
	Index1						= 6,	# index proximal phalange bone
	Index2						= 7,	# index intermediate phalange bone
	Index3						= 8,	# index distal phalange bone
	Middle1						= 9,	# middle proximal phalange bone
	Middle2						= 10,	# middle intermediate phalange bone
	Middle3						= 11,	# middle distal phalange bone
	Ring1						= 12,	# ring proximal phalange bone
	Ring2						= 13,	# ring intermediate phalange bone
	Ring3						= 14,	# ring distal phalange bone
	Pinky0						= 15,	# pinky metacarpal bone
	Pinky1						= 16,	# pinky proximal phalange bone
	Pinky2						= 17,	# pinky intermediate phalange bone
	Pinky3						= 18,	# pinky distal phalange bone
	MaxSkinnable				= 19,

	# Bone tips are position only. They are not used for skinning but useful for hit-testing.
	# NOTE: ThumbTip == MaxSkinnable since the extended tips need to be contiguous
	ThumbTip					= 19 + 0,	# tip of the thumb
	IndexTip					= 19 + 1,	# tip of the index finger
	MiddleTip					= 19 + 2,	# tip of the middle finger
	RingTip						= 19 + 3,	# tip of the ring finger
	PinkyTip					= 19 + 4,	# tip of the pinky
	Max 						= 19 + 5,
	EnumSize 					= 0x7fff
};

const _ovrHandFingers_Bone1Start = [ovrHandBone.Thumb1, ovrHandBone.Index1, ovrHandBone.Middle1, ovrHandBone.Ring1,ovrHandBone.Pinky1];


# we need to remap the bone ids from the hand model to the bone orientations we get from the vrapi and the inverse
# This is only for the actual bones and skips the tips (vrapi 19-23) as they do not need to be updated I think
const _vrapi2hand_bone_map = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];
# inverse mapping to get from the godot hand bone ids to the vrapi bone ids
const _hand2vrapi_bone_map = [0, 2, 3, 4, 5,19, 6, 7, 8, 20,  9, 10, 11, 21, 12, 13, 14, 22, 15, 16, 17, 18, 23, 1];

# we need the inverse neutral pose to compute the estimates for gesture detection
var _vrapi_inverse_neutral_pose = []; # this is filled when clearing the rest pose

var _hand_bone_mappings = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];

func _clear_bone_rest(skeleton : Skeleton):
	_vrapi_inverse_neutral_pose.resize(skeleton.get_bone_count());
	for i in range(0, skeleton.get_bone_count()):
		var bone_rest = skeleton.get_bone_rest(i);
		
		skeleton.set_bone_pose(i, Transform(bone_rest.basis)); # use the loaded rest as start pose
		
		_vrapi_inverse_neutral_pose[_hand2vrapi_bone_map[i]] = bone_rest.basis.get_rotation_quat().inverse();
		
		# we fill this array here also with the rest pose so on Desktop we still have a valid array
		_vrapi_bone_orientations[_hand2vrapi_bone_map[i]]  = bone_rest.basis.get_rotation_quat();
		
		bone_rest.basis = Basis(); # clear the rotation of the rest pose
		skeleton.set_bone_rest(i, bone_rest); # and set this as the rest pose for the skeleton

func update_bone_orientations(orientations, confidence = 1.0):
	hand_confidence = confidence
	for i in range(0, _hand_bone_mappings.size()):
		_vrapi_bone_orientations[i] = orientations[i]
		skel.set_bone_pose(_hand_bone_mappings[i], Transform(orientations[i]));

func show_hands():
	mesh.show()

func hide_hands():
	mesh.hide()

var hand_tracking = false	
func _ready():
	hand = get_parent().get_parent();
	if has_node("ArmatureRight"):
		skel = get_node("ArmatureRight/Skeleton")
		mesh = get_node("ArmatureRight/Skeleton/r_handMeshNode")
	else:
		skel = get_node("ArmatureLeft/Skeleton")
		mesh = get_node("ArmatureLeft/Skeleton/l_handMeshNode")
	claws = skel.get_node("middle_root_bone/claws")

	_vrapi_bone_orientations.resize(24)
	_clear_bone_rest(skel)
	

func _get_bone_angle_diff(orientations, ovrHandBone_id):
	var quat_diff = orientations[ovrHandBone_id] * _vrapi_inverse_neutral_pose[ovrHandBone_id];
	var a = acos(clamp(quat_diff.w, -1.0, 1.0));
	return rad2deg(a);

# For simple gesture detection we can just look at the state of the fingers
# and distinguish between bent and straight
enum SimpleFingerState {
	Bent = 0,
	Straight = 1,
	Inbetween = 2,
}

# this is a very basic heuristic to detect if a finger is straight or not.
# It is a bit unprecise on the thumb and pinky but overall is enough for very simple
# gesture detection; it uses the accumulated angle of the 3 bones in each finger
func get_finger_state_estimate(orientations, finger):
	var angle = 0.0;
	angle += _get_bone_angle_diff(orientations, _ovrHandFingers_Bone1Start[finger]+0);
	angle += _get_bone_angle_diff(orientations, _ovrHandFingers_Bone1Start[finger]+1);
	angle += _get_bone_angle_diff(orientations, _ovrHandFingers_Bone1Start[finger]+2);
	
	# !!TODO: thresholds need some finetuning here
	if (finger == ovrHandFingers.Thumb):
		if (angle <= 30): return SimpleFingerState.Straight;
		if (angle >= 35): return SimpleFingerState.Bent; # very low threshold here...
	elif (finger == ovrHandFingers.Pinky):
		if (angle <= 40): return SimpleFingerState.Straight;
		if (angle >= 60): return SimpleFingerState.Bent;
	else:
		if (angle <= 35): return SimpleFingerState.Straight;
		if (angle >= 75): return SimpleFingerState.Bent;
	return SimpleFingerState.Inbetween;

enum HandState {
	Open = 0,
	Fist = 1,
};

var state = HandState.Open;
var state_since_ts = 0;
var switching_threshold_ms = 100

func _process(delta):
	if beast_mode:
		if hand_confidence > 0.9:
			if is_fist() and state == HandState.Open:
				state = HandState.Fist
				state_since_ts = OS.get_ticks_msec()
			elif not is_fist() and state == HandState.Fist:
				state = HandState.Open
				state_since_ts = OS.get_ticks_msec()
			
			if claws.is_retracted() and state == HandState.Fist and OS.get_ticks_msec()  > state_since_ts + switching_threshold_ms:
				claws.extend()
			elif claws.is_extended() and state == HandState.Open and OS.get_ticks_msec()  > state_since_ts + switching_threshold_ms:
				claws.retract()
	elif claws.is_extended():
		claws.retract()


func is_fist():
	if hand_tracking:
		var thumb_state = get_finger_state_estimate(_vrapi_bone_orientations, ovrHandFingers.Thumb)
		var index_state = get_finger_state_estimate(_vrapi_bone_orientations, ovrHandFingers.Index)
		var middle_state = get_finger_state_estimate(_vrapi_bone_orientations, ovrHandFingers.Middle)
		return thumb_state == SimpleFingerState.Bent and index_state == SimpleFingerState.Bent and middle_state == SimpleFingerState.Bent
	return true	

var gu = GameUtilities.new()
func set_hand_active(value):
	#Deprecated
	pass
		
func get_ball_attachment():		
	if has_node("ArmatureRight"):
		return get_node("ArmatureRight/Skeleton/middle_root_bone/ball_attachment")
	else:
		return get_node("ArmatureLeft/Skeleton/middle_root_bone/ball_attachment")
		
func get_root():
	if has_node("ArmatureRight"):
		return get_node("ArmatureRight/Skeleton/wrist")
	else:
		return get_node("ArmatureLeft/Skeleton/wrist")
	


