//
//  ServerHandler.swift
//  AnagramReviewer
//
//  Created by Colin Rofls on 2014-08-02.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

import UIKit

struct AnagramPair {
    
}

class ServerHandler: NSObject {
    
    func requestHits(count: Int, status: String, olderThan: Int?) -> [AnagramPair] {
        var queryString = "count=\(count)&status=\(status)"
        if let olderThan = olderThan {
            queryString += "&cutoff\(olderThan)"
        }
        
    }
   
}
