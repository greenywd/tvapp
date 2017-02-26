import Foundation
import UIKit

class User {
	var name: String
 
	init(name: String) {
		self.name = name
		print("User \(name) is initialized")
	}
 
	deinit {
		print("User \(name) is being deallocated")
	}
}
do {
	let user1 = User(name: "John")
}

typealias UIColour = UIColor

let red = UIColour.red