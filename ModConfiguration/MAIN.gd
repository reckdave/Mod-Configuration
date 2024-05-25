extends Node

onready var CONFIG_MENU = preload("res://ModConfiguration/Scenes/Config_Menu.tscn")
onready var CONFIG_SETTINGS = preload("res://ModConfiguration/Scenes/Config_Setting.tscn")
onready var CONFIG_NODE = preload("res://ModConfiguration/Scenes/Config_Node.tscn")
onready var CONFIG_LIST = $CONFIG_NODES
onready var HTTP = $VersionRequest

const VERSION = '1.1.4'
const URL = "https://raw.githubusercontent.com/reckdave/Mod-Configuration/main/ModConfiguration/VERSION.json"
const trusted_mods = ["KinitoFIXES","deadname-deleter","ModConfig","kinitonoboot"]

var File_EXT = '.json' # The file extention of the file name
var Config_Path = 'user://config' # File path of the config folder

var ModConfig_Info := {'SHOW_APP':true, 'VERSION_CHECK':true}
var ModConfig_Author := 'reckdave' # me!!!
var ModConfig_Name := 'ModConfig'

var translation_contents

var Load_Time := 0.1

# MISC
func pr(string):
	print('[CONFIG] ', string)

func _ready():
	var dir = Directory.new()
	dir.open('user://') # Opens directory
	
	if !dir.dir_exists('config'): # Sees if the a folder called 'config' exists
		dir.make_dir('config') # Creates the folder
		pr('CONFIG FOLDER DOESNT EXIST.. CREATING')
	
	
	pr('STARTED, VER: %s' % VERSION) # Easier to help people because I can just ask their version number
	var ModConfig_Node = MakeConfig(ModConfig_Name,ModConfig_Author,ModConfig_Info)
	ModConfig_Info = ModConfig_Node.ConfigValues
	if ModConfig_Info["VERSION_CHECK"]:
		HTTP.request(URL)

func MakeConfig(Config_Name := "NULL",Author := "NULL",Info := {}): # The real stuff happens here
	if Info == null or Info.empty(): # Checks if the dictionary is empty or null
		pr('%s DICTIONARY DOESNT EXIST / IS EMPTY.. CANCELLED' % Config_Name)
		return
	
	# GETS INFO / CREATES INFO
	
	var Config_File = File.new() # The actual file
	var Config_Final = CONFIG_NODE.instance() # Clones the node
	Config_Final.name = Config_Name
	Config_Final.ConfigValues = Info # Store the values
	Config_Final.ModAuthor = Author
	var FullDir = Config_Path + '/' + Config_Name + File_EXT # Full thing example: 'user://config/Example.json'
	var Dir = Directory.new()
	Dir.open(Config_Path)
	
	# DIRECTORY CHECK
	
	if !Dir.file_exists(FullDir): # Checks if the file exists
		pr('CREATING %s' % Config_Name)
		Config_File.open(FullDir,File.WRITE)
		Config_File.store_string(JSON.print(Info,'\t')) # Stores the data
	else: # Load the config file if it does
		pr(Config_Name + ' FOUND')
		Config_File.open(FullDir,File.READ_WRITE)
		var JSON_Content = Config_File.get_as_text() # Reads the file
		var Validated_JSON = validate_json(JSON_Content) # Checks if the file is o'okay
		
		# CHECKS IF ITS A VALID JSON
		
		if !Validated_JSON:
			pr('VALID JSON: %s' % Config_Name + File_EXT)
		else:
			pr('INVALID JSON: %s' % Config_Name + File_EXT)
			return
		var Contents : Dictionary = str2var(JSON_Content)
		
		# CHECK FOR MISSING KEY
		
		for key in Info:
			if key in Contents:
				pr("found")
			else:
				pr(Info[key])
				Contents[key] = Info[key]
			
		# STORES THE INFO
		
		Config_File.store_string(JSON.print(Contents,'\t'))
		Config_Final.ConfigValues = Contents # Actually store the values
		pr(Contents)
	
	# ADDS THE NODE / CONFIG
	
	CONFIG_LIST.add_child(Config_Final) # Add the node to the `CONFIG_NODES`
	Config_File.close() # Close the file since we dont need it anymore
	
	# TRUSTED CHECK
	
	Config_Final.Trusted = false
	for trusted_mod_num in range(trusted_mods.size()):
		if Config_Name == trusted_mods[trusted_mod_num]:
			pr(Config_Name)
			Config_Final.Trusted = true
			break
	
	return Config_Final # Give the node to the modder


# APP HANDLER
var CAN_OPEN = true
var FINISHED_LOADING = false
var replaced = false

func _save_config():
	var applic = get_parent().get_parent().get_node("0").get_child(0)
	var menu = applic.get_node('Menu_CONFIG')
	var LIST_BOX = menu.get_node("Active/Config_Container/List")
	var x_button = menu.get_node('Active/XButton')
	for config_nodes in range(CONFIG_LIST.get_child_count()):
				var node = CONFIG_LIST.get_child(config_nodes)
				var Config_Name = node.name
				var FullDir = Config_Path + '/' + Config_Name + File_EXT
				for config_values in range(node.ConfigValues.size()):
					var Config_Title = node.ConfigValues.keys()[config_values]
					var Config_Setting = LIST_BOX.get_node(Config_Name + '_' + Config_Title)
					var Config_Value = Config_Setting.config_value
					node.ConfigValues[Config_Title] = Config_Value
					pr(Config_Value)
				var file = File.new()
				file.open(FullDir,File.WRITE)
				file.store_string(JSON.print(node.ConfigValues,'\t'))
				file.close()
func _process(delta):
	if FINISHED_LOADING and !CAN_OPEN:
		var applic = get_parent().get_parent().get_node("0").get_child(0)
		var menu = applic.get_node('Menu_CONFIG')
		var x_button = menu.get_node('Active/XButton')
		if x_button.pressed == true:
			CAN_OPEN = true
			_save_config()
			menu.get_node('ANIMATIONS').play('0')
			yield(get_tree().create_timer(0.2,false),"timeout")
			menu.queue_free()
	if ModConfig_Info['SHOW_APP']:
		if !get_parent().get_parent().has_node("0"): return
		if get_parent().get_parent().get_node("0").get_child(0) == null: return
		if "PC" in get_parent().get_parent().get_node('0').get_child(0).name:
			#PC_SCENE = true
			var applic = get_parent().get_parent().get_node("0").get_child(0)
			if applic.get_node('Aspect').has_node('ConfigAPP'): return # STOPS FROM OVER FLOWING THE PC
			var dskObject = load("res://-Scenes/Application000/Sub/Desktop_Object.tscn").instance()
			dskObject.name = 'ConfigAPP'
			dskObject.Name = 'Mod Config'
			dskObject.ButtonNumber = 6068
			dskObject.DskTexture = load("res://-Asset/App000/PC/Icons/Settings.png")
			applic.get_node('Aspect').add_child(dskObject)

func _input(event):
	if event is InputEventMouseButton:
		if event.doubleclick and event.button_index == BUTTON_LEFT:
			if (Tab.buttonValue == 6068) and CAN_OPEN:
				var applic = get_parent().get_parent().get_node("0").get_child(0)
				var MENU = CONFIG_MENU.instance()
				var LIST_BOX = MENU.get_node("Active/Config_Container/List")
				MENU.config_node = self
				applic.add_child(MENU)
				MENU.get_node('ANIMATIONS').play('1')
				MENU.position = Vector2(40,40)
				FINISHED_LOADING = false
				CAN_OPEN = false
				for config_nodes in range(CONFIG_LIST.get_child_count()):
					var node = CONFIG_LIST.get_child(config_nodes)
					var Config_Header = CONFIG_SETTINGS.instance()
					var Config_Name = node.name
					var Config_Author = node.ModAuthor
					var Config_Header_Anim = Config_Header.get_node("ANIMATION")
					Config_Header.editable = false
					Config_Header.config_title = Config_Name + ' by [wave]' + Config_Author
					Config_Header.get_node("ACTIVE/TrustedImage").visible = node.Trusted
					LIST_BOX.add_child(Config_Header)
					Config_Header_Anim.play("0")
					yield(get_tree().create_timer(Load_Time,false),"timeout")
					for config_values in range(node.ConfigValues.size()):
						var Config_Setting = CONFIG_SETTINGS.instance()
						var Config_Title = node.ConfigValues.keys()[config_values]
						var Config_Value = node.ConfigValues[Config_Title]
						var Config_Setting_Anim = Config_Setting.get_node("ANIMATION")
						Config_Setting.config_title = Config_Title
						Config_Setting.config_value = Config_Value
						Config_Setting.name = Config_Name + '_' + Config_Title
						LIST_BOX.add_child(Config_Setting)
						Config_Setting_Anim.play('0')
						yield(get_tree().create_timer(Load_Time,false),"timeout")
				var Space_NODE = Control.new()
				Space_NODE.name = "SPACE"
				LIST_BOX.add_child(Space_NODE)
				FINISHED_LOADING = true

# UPDATE CHECK

func _request_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = str2var(body.get_string_from_utf8())
		pr(data["VERSION"])
		if VERSION < data["VERSION"]:
			OS.alert("THIS IS AN OUTDATED VERSION OF MODCONFIG \nDOWNLOAD LATEST AT THE GITHUB","MOD CONFIG")
			OS.shell_open("https://github.com/reckdave/Mod-Configuration/releases/tag/release%s" % data["VERSION"])
	else:
		pr('FAILED TO GET VERSION NUMBER: ' + response_code)
