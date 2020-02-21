extends CanvasLayer

func _ready():
	update_inventory()

func update_inventory():
	$Inventory/Iron/Label.text = "Iron Ore: %s" % global.inventory.get("Iron Ore", 0)
