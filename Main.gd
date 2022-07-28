extends Node

var server := UDPServer.new()
var peers = []
onready var board = get_node("Board")
var current_x_angle = 0
var current_y_angle = 0
var current_z_angle = 0

var x_angle_offset = 0
var y_angle_offset = 0
var z_angle_offset = 0

func _ready():
	server.listen(50000)

func _process(delta):
	server.poll()
	if server.is_connection_available():
		# listen for packet
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		var received = pkt.get_string_from_utf8()
		# parse angles
		var angles = received.rsplit(",")
		var x_angle = float(angles[0].rsplit(":")[1]) * (PI/180)
		var y_angle = float(angles[1].rsplit(":")[1]) * (PI/180)
		var z_angle = float(angles[2].rsplit(":")[1]) * (PI/180)
		print("X: %.2f Y: %.2f Z: %.2f" % [x_angle, y_angle, z_angle])
		# rotate by offset
		x_angle_offset = x_angle - current_x_angle
		y_angle_offset = y_angle - current_y_angle
		z_angle_offset = z_angle - current_z_angle
		board.rotate_x(-x_angle_offset)
		board.rotate_z(y_angle_offset)
		board.rotate_y(z_angle_offset)
		current_x_angle = x_angle
		current_y_angle = y_angle
		current_z_angle = z_angle
		# reset rotation if esc is pressed
		if Input.is_action_pressed("reset_angles"):
			print("Reset angles")
			board.rotate_x(x_angle)
			board.rotate_y(-y_angle)
			board.rotate_z(-z_angle)
