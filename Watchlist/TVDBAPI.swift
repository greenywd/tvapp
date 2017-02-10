//
//  TVDBAPI.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 28/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import Alamofire

class TVDBAPI {
    let APIKey: String = "E68919A992B81F36"
    //var detailsOfShow = SearchingShows()
    //var token: String? = nil
    
    func loginWithKey(key: String){
        print("Grabbing token...")
        let parameters: [String: Any] = ["apikey":key]
        var loginResponse = [String: String]()
    
        Alamofire.request("https://api.thetvdb.com/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
                    
            if let result = response.result.value {
                loginResponse = (result as? Dictionary)!
                //print(self.loginResponse["token"]!)
                
                if loginResponse["token"] != nil{
                    tokenForAPI = loginResponse["token"]!
                    print("TOKEN IS: \(tokenForAPI!)")
                }
            }
        }
    }
    
	func getDetailsOfShow(id: Int, callback: @escaping ((_ data: [String: Any]?, _ imageURL: String?, _ err: Error?)->Void)) {
		//var details = detailsOfShow
        let seriesURL = "https://api.thetvdb.com/series/" + String(id)
		print("URL: \(seriesURL)")
        var headers: HTTPHeaders
		
        if tokenForAPI != nil{
            headers = [
                "Authorization": "Bearer \(tokenForAPI!)",
                "Accept": "application/json"
            ]
			
            Alamofire.request(seriesURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.value != nil {
                    let result = JSON(response.result.value!).dictionaryValue
                    print(result)
                    
                    if result["Error"] == nil{
                        //TODO: Finish implementing this for ShowVC
						
						if result["data"]?["seriesName"] != nil {
							detailsForController["name"] = result["data"]!["seriesName"].stringValue
						}
						if result["data"]?["overview"] != nil {
							detailsForController["description"] = result["data"]!["overview"].stringValue
						}
						if result["data"]?["id"] != nil {
							//showIDFromSearch.append(((result["data"]?["id"])?.uIntValue)!)
						}
						
//						callback(result, nil, nil)
						//let resolution = "1920x1080" //maybe an option to change resolution???
						let imageURL = "https://api.thetvdb.com/series/257655/images/query?keyType=fanart&resolution=1920x1080"
						print("IMAGE URL: \(imageURL)")
						Alamofire.request(imageURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
							if response.result.value != nil {
								let result = JSON(response.result.value!).dictionaryValue
								print(result)
								
								if result["Error"] == nil && result["data"]?[0]["fileName"] != nil {
									showArtworkURL = URL(string: "https://thetvdb.com/banners/\(result["data"]![0]["fileName"].stringValue)")
									print(showArtworkURL)
									//TODO: GD CALLBACK WEN RELEES
									callback(result, showArtworkURL?.absoluteString, nil)
								} else {
									callback(nil, nil, NSError(domain: "WatchListErrorDomain", code: -10, userInfo: ["message": result["Error"]!]))
								}
							} else {
								callback(nil, nil, response.result.error)
							}
						}

						
                    } else {
						callback(nil, nil, NSError(domain: "WatchListErrorDomain", code: -10, userInfo: ["message": result["Error"]!]))
                    }
				} else {
					callback(nil, nil, response.result.error)
				}
            }
		}
	}
	
    func searchShows(show: String) {
        let URL = "https://api.thetvdb.com/search/series?name=" + show.replacingOccurrences(of: " ", with: "%20")
        var headers: HTTPHeaders
		print("URL: \(URL)")
		
        if tokenForAPI != nil{
            headers = [
                "Authorization": "Bearer \(tokenForAPI!)",
                "Accept": "application/json"
            ]
            print("searching...")
            Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                print(response)
                if response.result.value != nil {
    
                    let result = JSON(response.result.value!).dictionaryValue
                    if result["Error"] == nil {
                        let numberOfItems:Int = (result["data"]?.count)!
                        
                        print("\(numberOfItems) entries.")
                        for count in 0..<numberOfItems {
                            if result["data"]?[count]["seriesName"] != nil {
                                showNamesFromSearch.append(((result["data"]?[count]["seriesName"])?.stringValue)!)
                            }
                            if result["data"]?[count]["overview"] != nil {
                                showDescFromSearch.append(((result["data"]?[count]["overview"])?.stringValue)!)
                            }
                            if result["data"]?[count]["id"] != nil {
                                showIDFromSearch.append(((result["data"]?[count]["id"])?.intValue)!)
                            }
                            
                        }
                        print(showNamesFromSearch)
                        print(showDescFromSearch)
                        print(showIDFromSearch)
                        
                        let notificationName = Notification.Name("load")
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                    
                    return
                }
            }
        }
    }
}
