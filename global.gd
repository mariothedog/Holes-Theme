extends Node

func random_number(mini, maxi): # Max number is excluded
	return range(mini,maxi)[randi()%range(mini,maxi).size()]

# warning-ignore:unused_class_variable
var ore_positions = {}
# warning-ignore:unused_class_variable
var hole_positions = {}
# warning-ignore:unused_class_variable
var recent_landing_asteroid_pos

# warning-ignore:unused_class_variable
var inventory = {}
