extends Node

func random_number(mini, maxi): # Max number is excluded
	return range(mini,maxi)[randi()%range(mini,maxi).size()]

var ore_positions = {}
var hole_positions = {}
var recent_landing_asteroid_pos

var inventory = {}
