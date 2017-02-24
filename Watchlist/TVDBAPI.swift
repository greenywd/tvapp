//
//  TVDBAPI.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 28/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import Alamofire

struct Episode {
	var name: String
	var season: Int
	var episode: Int
	var overview: String?
	var id: Int
}

struct Season {
	var number: Int
	var episodes: [Episode]
}

class TVDBAPI {
	let APIKey: String = "E68919A992B81F36"
	
	func loginWithKey(key: String){
		print("Grabbing token...")
		let parameters: [String: Any] = ["apikey":key]
		var loginResponse = [String: String]()
		
		Alamofire.request("https://api.thetvdb.com/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
			
			if let result = response.result.value {
				loginResponse = (result as? Dictionary)!
				
				if loginResponse["token"] != nil{
					tokenForAPI = loginResponse["token"]!
					print("TOKEN IS: \(tokenForAPI!)")
				}
			}
		}
	}
	
	func getDetailsOfShow(id: Int, callback: @escaping ((_ data: [String: Any]?, _ imageURL: String?, _ err: Error?)->Void)) {
		
		let seriesURL = "https://api.thetvdb.com/series/" + String(id)
		print("URL: \(seriesURL)")
		var headers: HTTPHeaders
		
		var imageURL = "https://api.thetvdb.com/series/\(String(id))/images/query?keyType=fanart&resolution=1280x720"
		print("IMAGE URL: \(imageURL)")
		
		if tokenForAPI != nil{
			headers = [
				"Authorization": "Bearer \(tokenForAPI!)",
				"Accept": "application/json"
			]
			
			Alamofire.request(seriesURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
				if response.result.value != nil {
					let result = JSON(response.result.value!).dictionaryValue
					
					if result["Error"] == nil{
						
						if result["data"]?["seriesName"] != nil {
							detailsForController["name"] = result["data"]!["seriesName"].stringValue
						}
						if result["data"]?["overview"] != nil {
							detailsForController["description"] = result["data"]!["overview"].stringValue
						}
						
						Alamofire.request(imageURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
							if response.result.value != nil {
								let result = JSON(response.result.value!).dictionaryValue
								//print(result)
								
								if result["Error"] == nil && result["data"]?[0]["fileName"] != nil {
									showArtworkURL = URL(string: "https://thetvdb.com/banners/\(result["data"]![0]["fileName"].stringValue)")
									print("SHOW ARTWORK \(String(describing: showArtworkURL?.absoluteString))")
									
									callback(result, showArtworkURL?.absoluteString, nil)
								} else if result["Error"] != nil {
									print("No results for 720p found. Trying 1080p...")
									imageURL = "https://api.thetvdb.com/series/\(String(id))/images/query?keyType=fanart&resolution=1920x1080"
									
									Alamofire.request(imageURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
										if response.result.value != nil {
											let result = JSON(response.result.value!).dictionaryValue
											//print(result)
											
											if result["Error"] == nil && result["data"]?[0]["fileName"] != nil {
												showArtworkURL = URL(string: "https://thetvdb.com/banners/\(result["data"]![0]["fileName"].stringValue)")
												print("SHOW ARTWORK \(String(describing: showArtworkURL?.absoluteString))")
												
												callback(result, showArtworkURL?.absoluteString, nil)
											}
											
										}
									}
									
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
		let notificationName = Notification.Name("load")
		
		print("URL: \(URL)")
		
		if tokenForAPI != nil{
			headers = [
				"Authorization": "Bearer \(tokenForAPI!)",
				"Accept": "application/json"
			]
			print("Searching for \(show)...")
			Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
				if response.result.value != nil {
					
					let result = JSON(response.result.value!).dictionaryValue
					if result["Error"] == nil {
						let numberOfItems:Int = (result["data"]?.count)!
						
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
						
						NotificationCenter.default.post(name: notificationName, object: nil)
						
					} else {
						showNamesFromSearch.removeAll()
						showNamesFromSearch.append("Not Found.")
						showDescFromSearch.removeAll()
						showDescFromSearch.append("Not Found.")
						
						NotificationCenter.default.post(name: notificationName, object: nil)
					}
					
					return
				}
			}
		}
	}
	
	func jsonToSeasonArray(_ arr: [String: JSON]) -> [Season] {
		var seasons = [Int: Season]()
		
		let episodes = arr["data"]!.arrayValue
		for episode in episodes {
			let seasonNum = episode["airedSeason"].intValue
			let episodeNum = episode["airedEpisodeNumber"].intValue
			let episodeName = episode["episodeName"].stringValue
			let overview = episode["overview"].stringValue
			let id = episode["id"].intValue
			
			let newEpisode = Episode(name: episodeName, season: seasonNum, episode: episodeNum, overview: overview, id: id)
			
			if seasons.keys.contains(seasonNum) {
				seasons[seasonNum]!.episodes.append(newEpisode)
			} else {
				let newSeason = Season(number: seasonNum, episodes: [newEpisode])
				seasons[seasonNum] = newSeason
			}
		}
		let finalSeasons = seasons.map({ key, value -> Season in
			var value = value
			value.episodes = value.episodes.sorted { (left, right) -> Bool in
				return left.episode < right.episode
			}
			return value
		}).sorted(by: {left, right in left.number < right.number})
		return finalSeasons
	}
	
	func mergeSeasonArray(_ arr : [Season]) -> [Season] {
		var seasonsDict = [Int: Season]()
		for season in arr {
			if seasonsDict.keys.contains(season.number) {
				seasonsDict[season.number]!.episodes.append(contentsOf: season.episodes)
			} else {
				seasonsDict[season.number] = season
			}
		}
		
		let finalSeasons = seasonsDict.map({ key, value -> Season in
			var value = value
			value.episodes = value.episodes.sorted { (left, right) -> Bool in
				return left.episode < right.episode
			}
			return value
		}).sorted(by: {left, right in left.number < right.number})
		return finalSeasons
	}
	
	func getEpisodesForShow(id: Int, callback: @escaping (_ seasons: [Season]?, _ err: Error?)->Void) {
		let episodesURL = "https://api.thetvdb.com/series/\(id)/episodes"
		var headers: HTTPHeaders
		
		if tokenForAPI != nil{
			headers = [
				"Authorization": "Bearer \(tokenForAPI!)",
				"Accept": "application/json"
			]
			
			Alamofire.request(episodesURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
				if response.result.value != nil {
					let result = JSON(response.result.value!).dictionaryValue
					print(result)
					if result["Error"] == nil {
						// Paging
						
						// URL: https://api.thetvdb.com/series/{ID}/episodes/query?page=2
						
						var finalSeasons = self.jsonToSeasonArray(result)
						
						let lastPage = result["links"]!["last"].intValue
						
						var pagesDone = 1
						if pagesDone == lastPage {
							callback(finalSeasons, nil)
							
							let notificationName = Notification.Name("reloadEpisodes")
							NotificationCenter.default.post(name: notificationName, object: nil)
							return
						}
						
						for page in 2...lastPage {
							Alamofire.request("https://api.thetvdb.com/series/\(id)/episodes/query?page=\(page)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
								if response.result.value != nil {
									let result = JSON(response.result.value!).dictionaryValue
									
									if result["Error"] == nil {
										// Paging
										
										// URL: https://api.thetvdb.com/series/{ID}/episodes/query?page=2
										
										finalSeasons.append(contentsOf: self.jsonToSeasonArray(result))
										pagesDone += 1
										
										if pagesDone == lastPage {
											callback(self.mergeSeasonArray(finalSeasons), nil)
											
											let notificationName = Notification.Name("reloadEpisodes")
											NotificationCenter.default.post(name: notificationName, object: nil)
										}
									} else {
										callback(nil, NSError(domain: "WatchListErrorDomain", code: -11, userInfo: ["message": result["Error"]!]))
										return
									}
								} else {
									callback(nil, response.result.error)
									return
								}
								
							}
							
						}
					} else {
						callback(nil, NSError(domain: "WatchListErrorDomain", code: -11, userInfo: ["message": result["Error"]!]))
					}
				} else {
					callback(nil, response.result.error)
				}
			}
		}
	}
	
	
}
