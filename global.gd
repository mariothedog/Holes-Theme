extends Node

func random_number(mini, maxi): # Max number is excluded
	return range(mini,maxi)[randi()%range(mini,maxi).size()]
