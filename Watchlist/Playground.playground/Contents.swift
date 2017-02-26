import Foundation

struct Show {
	var title: String
	var id: Int
	var description: String
	
	init (title: String = "Title", id: Int = 123456, description: String = "Description") {
		self.title = title
		self.id = id
		self.description = description
	}
}

let detailsOfShow = [
	
	"name" : String(),
	"description" : String(),
	"id" : String(),
	
	] as [String : Any]

var x = detailsOfShow
x["description"] = "test test test"
//print(x["description"]!)

var testdict = ["The Flash (2014)": 279121, "Arrow": 257655, "Westworld": 296762]

var z = [Show]()

for (key, value) in testdict {
	//print(key, "|", value)
	z.append(Show(title: key, id: value, description: "test"))
}

//print(z.map({ print($0.title) }))

let sortedDictArray = testdict.sorted(by: <)
var arrayOfTitles = [String]()
//for (key, value) in sortedDict{
//	print(key, value)
//	arrayOfTitles.append(key)
//}

sortedDictArray.map({ arrayOfTitles.append($0.key) })

print(arrayOfTitles)

func myPrintFunc(_ string: Any){
	print(string)
}

let array = [1, 2, 3, 4]
array.map({ myPrintFunc($0) })

for element in array {
	print(element)
}

array.contains(1) ? print("woo") : print("noo")


