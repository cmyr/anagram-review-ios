//
//  ServerHandler.swift
//  AnagramReviewer
//
//  Created by Colin Rofls on 2014-08-02.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

import UIKit


struct Tweet : Printable {
    let profileImageURL: String!
    let tweetID: Int!
    let screenName: String!
    let text: String!
    let userName: String!
    let createdAt: NSDate!
    var profileImage: UIImage?
    
    var description : String {
        return "\(tweetID) \(createdAt.description) \n \(userName) \(screenName) \n \(text)"
    }
    init(json: JSONValue) {
        if let tweetText = json["tweet_text"].string {
            text = tweetText
        }else{
            text = ""
        }
        if let idInt = json["tweet_id"].integer {
            tweetID = idInt
        }else{
            tweetID = 0
        }
        if let createdString = json["fetched"]["created_at"].string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z Y"
            createdAt = dateFormatter.dateFromString(createdString)
        }else{
            createdAt = NSDate(timeIntervalSinceReferenceDate: 0)
        }
        if let name = json["fetched"]["user"]["name"].string {
                userName = name
            }else{
                userName = ""
            }
        if let sName = json["fetched"]["user"]["screen_name"].string {
            screenName = sName
        }else{
            screenName = ""
        }
        if let imgURL = json["fetched"]["user"]["profile_image_url"].string {
            profileImageURL = imgURL
        }else{
            profileImageURL = ""
        }
    }


    func debug_description() -> String {
        return "\(tweetID) \(createdAt.description) \n \(userName) \(screenName) \n \(text)"
    }
}


struct AnagramPair : Printable {
    var hitID : Int!
    var hitHash : String!
    var status : String!
    var tweet1 : Tweet!
    var tweet2: Tweet!
    
    var description : String {
        return "\(hitID), \(status) \n \(tweet1.description)\n\(tweet2.description)"
    }
    
    init(json: JSONValue) {
        if let idInt = json["id"].integer {
            hitID = idInt
        }else{
            hitID = 0
        }
        if let hitStatus = json["status"].string {
            status = hitStatus
        }else{
            status = "no status"
        }
            tweet1 = Tweet(json: json["tweet_one"])
            tweet2 = Tweet(json: json["tweet_two"])
        }
    
}

enum ServerResponse {
    case Success(JSONValue)
    case Error(String)
}



class ServerHandler: NSObject {
    
    func requestHits(count: Int, status: String, olderThan: Int?) -> [AnagramPair] {
        var queryString = "count=\(count)&status=\(status)"
        if let olderThan = olderThan {
            queryString += "&cutoff\(olderThan)"
        }
        
        let urlString = ANR_BASE_URL + "/hits?" + queryString
        let req = NSMutableURLRequest(URL:(NSURL(string: urlString)))
        req.addValue(ANR_AUTH_TOKEN, forHTTPHeaderField: "Authorization")
        
        let response = _request(req)
        
        switch response {
        case let .Success(json):
            println("recieved json \(json)")
        case let .Error(error):
            println("failed with error \(error)")
        }
        
        return [AnagramPair]()
        
    }
    
    func _request(req: NSURLRequest) -> ServerResponse {
        var response: NSURLResponse?
        var error: NSError?
        NSURLRequest.setAllowsAnyHTTPSCertificate(true, forHost: ANR_HOST)
        let data: NSData? = NSURLConnection.sendSynchronousRequest(req,
            returningResponse: &response, error: &error);
        
        if let error = error {
            return ServerResponse.Error(error.localizedDescription)
        }
        
        let jsonValue = JSONValue(data!)
        
        return ServerResponse.Success(jsonValue)
    }
   
}
