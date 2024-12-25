extends Control

const port = 5555
var peer = ENetMultiplayerPeer.new()
var ipad : String
var players = {}
var player = preload("res://scenes/player.tscn")

func _ready():
	if OS.get_name() == "Windows":
		ipad = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ipad = IP.get_local_addresses()[0]
	else:
		ipad = IP.get_local_addresses()[3]

	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			ipad = ip
	%Ip.text = ipad

func _on_btn_host_pressed():
	if OS.get_name() == "Android":
		peer.set_bind_ip(ipad)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.server_disconnected.connect(server_delete)
	hide()
	add_player(multiplayer.get_unique_id())

func _on_btn_join_pressed():
	if %joinIP.text == "":
		print("Put an IP Address!")
		return
	peer.create_client(%joinIP.text, port)
	multiplayer.multiplayer_peer = peer
	hide()

func add_player(id):
	print(str(id) + " has joined!")
	var player_new = player.instantiate()
	player_new.name = str(id)
	get_parent().get_node("PlayerSpawn").add_child(player_new)
	players[id] = player_new

func remove_player(id):
	print(str(id) + " has left!")

	# Remove from scene tree
	if id in players:
		var p = players[id]
		p.queue_free()
		# Remove from players dict
		players.erase(id)
		
		if len(players) == 0:
			server_delete()

func server_delete():
	# Disconnect all clients first
	for id in players.keys():
		multiplayer.peer_disconnect_remote(int(id), 0)

	# Stop hosting the server itself now.
	multiplayer.stop_server()

	print("Server host has disconnected!")

func _on_copy_pressed():
	DisplayServer.clipboard_set(%Ip.text)
