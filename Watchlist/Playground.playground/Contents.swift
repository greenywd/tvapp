func get_hand_total(hand: Array<Int>) -> Int{
	return hand.reduce(0, +)
}

var player_hand = [2, 5, 7, 2]

var value = get_hand_total(hand: player_hand)

player_hand[1] = 4

value
get_hand_total(hand: player_hand)