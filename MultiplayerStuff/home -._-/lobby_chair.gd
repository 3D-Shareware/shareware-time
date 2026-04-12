extends HomeBodyInteract


var enabled = false
var homebody : HomeBody = null
@onready var headset: Node3D = $headset
var org_trans : Transform3D
@onready var seat: Marker3D = $seat

func _ready() -> void:
	org_trans = headset.global_transform

	
func interact(body:HomeBody):
	if enabled == true: return
	enabled = true
	body.sitting_in_chair = true
	homebody = body
	var tween = create_tween()
	tween.tween_property(body, "global_transform", seat.global_transform, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	await homebody.play_headset_anim()
	var tween2 = create_tween()
	tween2.tween_property(headset, "global_position", body.camera.global_position + (body.camera.basis.x * .2) , .1)
	var lobby_container = get_tree().get_first_node_in_group("LobbyContainer")
	if lobby_container: #HACK
		lobby_container.get_node('LobbyViewer').open()


func leave_chair():
	enabled = false
	homebody.sitting_in_chair = false
	homebody = null
	
	var tween2 = create_tween()
	tween2.tween_property(headset, "global_transform", org_trans, .5)
	
	var lobby_container = get_tree().get_first_node_in_group("LobbyContainer")
	if lobby_container: #HACK
		lobby_container.get_node('LobbyViewer').close()
	
