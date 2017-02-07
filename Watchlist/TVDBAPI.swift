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
    let APIKey: String = "BE5F53398FC1FB01"
    //var detailsOfShow = SearchingShows()
    //var token: String? = nil
    
    func loginWithKey(key: String){
        print("Grabbing token...")
        let parameters: [String: Any] = ["apikey":key]
        var loginResponse = [String: String]()
    
        Alamofire.request("https://api.thetvdb.com/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            //print(response)
                    
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
    
	func getDetailsOfShow(id: Int) {
		//var details = detailsOfShow
        let URL = "https://api.thetvdb.com/series/" + String(id)
        var headers: HTTPHeaders
        
        if tokenForAPI != nil{
            headers = [
                "Authorization": "Bearer \(tokenForAPI!)",
                "Accept": "application/json"
            ]
            
            Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.value != nil {
                    let result = JSON(response.result.value!).dictionaryValue
                    print(result)
                    
                    if result["Error"] == nil{
                        //TODO: Implement this
						
						if result["data"]?["seriesName"] != nil {
							print("LOOK OHERE")
							print(result["data"]?["seriesName"].stringValue)
							detailsForController["name"] = result["data"]?["seriesName"].stringValue
							print(detailsForController["name"]!)
							//showNamesFromSearch.append(((result["data"]?["seriesName"])?.stringValue)!)
						}
						if result["data"]?["overview"] != nil {
							//showDescFromSearch.append(((result["data"]?["overview"])?.stringValue)!)
						}
						if result["data"]?["id"] != nil {
							//showIDFromSearch.append(((result["data"]?["id"])?.uIntValue)!)
						}

						//return details
						
						
                    } else {
                        //let error = thing["Error"]
                        //print("Error : \(error ?? "error not found")")
                    }
                }
            }
        }
    }
    
    func searchShows(show: String) {
        let URL = "https://api.thetvdb.com/search/series?name=" + show.replacingOccurrences(of: " ", with: "%20")
        var headers: HTTPHeaders
        
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
