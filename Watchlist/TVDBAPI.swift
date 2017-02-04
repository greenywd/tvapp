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
                //self.getDeatilsOfShow(id: 289590)
                //self.searchShows(show: "Arrow")
            }
        }
    }
    
    func getDeatilsOfShow(id: Int) {
        let URL = "https://api.thetvdb.com/series/" + String(id)
        var headers: HTTPHeaders
        
        if tokenForAPI != nil{
            headers = [
                "Authorization": "Bearer \(tokenForAPI!)",
                "Accept": "application/json"
            ]
            
            Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.value != nil {
                    let thing = JSON(response.result.value!).dictionaryValue
                    //print(thing)
                    
                    if thing["Error"] == nil{
                        //to-do
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
    
                    let thing = JSON(response.result.value!).dictionaryValue
                    if thing["Error"] == nil {
                        let numberOfItems:Int = (thing["data"]?.count)!
                        
                        print("\(numberOfItems) entries.")
                        for count in 0..<numberOfItems {
                            if thing["data"]?[count]["seriesName"] != nil {
                                showNamesFromSearch.append(((thing["data"]?[count]["seriesName"])?.stringValue)!)
                            }
                            if thing["data"]?[count]["overview"] != nil {
                                showDescFromSearch.append(((thing["data"]?[count]["overview"])?.stringValue)!)
                            }
                            
                        }
                        print(showNamesFromSearch)
                        print(showDescFromSearch)
                        let notificationName = Notification.Name("load")
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                    return
                    
                    /*if thing["data"]?[count]["overview"].string != nil{
                        //searchDetails.description.append((thing["data"]?[count]["overview"].string)!)
                        //    print(searchDetails.description)
                    } else {
                        //searchDetails.description.append("No Overview.")
                    }*/
                }
            }
        }
    }
}
