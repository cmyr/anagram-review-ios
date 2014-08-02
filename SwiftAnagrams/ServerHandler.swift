//
//  ServerHandler.swift
//  AnagramReviewer
//
//  Created by Colin Rofls on 2014-08-02.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

import UIKit


struct Tweet {
    let profileImageURL: String!
    let tweetID: Int!
    let screenName: String!
    let text: String!
    let userName: String!
    let createdAt: NSDate!
    var profileImage: UIImage?
    
    init(json: Dictionary<String, JSONValue>) {
        if let tweetText = json["text"]?.string {
            text = tweetText
        }
        if let idInt = json["id_str"]?.string?.toInt() {
            tweetID = idInt
        }
        if let createdString = json["created_at"]?.string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z Y"
            createdAt = dateFormatter.dateFromString(createdString)
        }
        if let user = json["user"]?.object {
            if let name = user["name"]?.string {
                userName = name
            }
            if let sName = user["screen_name"]?.string {
                screenName = sName
            }
            if let imgURL = user["profile_image_url"]?.string {
                profileImageURL = imgURL
            }
        }
    }
}


struct AnagramPair {
    let hitID : Int!
    let hitHash : String!
    let status : String!
    let tweet1 : Tweet!
    let tweet2: Tweet!
    
    init(json: JSONValue) {
        if let idInt = json["id"].string?.toInt() {
            hitID = idInt
        }
        if let hitStatus = json["status"].string {
            status = hitStatus
        }
        if let tweet1JSON = json["tweet_one"].object {
            tweet1 = Tweet(json: tweet1JSON)
        }
        if let tweet2JSON = json["tweet_two"].object {
            tweet2 = Tweet(json: tweet2JSON)
        }
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
