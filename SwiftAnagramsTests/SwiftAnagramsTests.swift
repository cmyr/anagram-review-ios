//
//  SwiftAnagramsTests.swift
//  SwiftAnagramsTests
//
//  Created by Colin Rofls on 2014-08-02.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

import UIKit
import XCTest

class SwiftAnagramsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let serverHandler = ServerHandler()
        let testURL = ANR_BASE_URL + "/hits?count=10&status=review"
        let request = NSMutableURLRequest(URL: NSURL(string: testURL))
        request.addValue(ANR_AUTH_TOKEN, forHTTPHeaderField: "Authorization")
        
        let response = serverHandler._request(request)
        
        switch response {
        case let .Success(json):
            println("chill")
        case let .Error(error):
            println("bummer")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            let serverHandler = ServerHandler()
            let testURL = ANR_BASE_URL + "/hits?count=10&status=review"
            let request = NSMutableURLRequest(URL: NSURL(string: testURL))
            request.addValue(ANR_AUTH_TOKEN, forHTTPHeaderField: "Authorization")
            
            let response = serverHandler._request(request)
            
            
            // Put the code you want to measure the time of here.
        }
    }
    

    func testJSONParsing() {
        
        let fileName : String? = NSBundle(forClass: SwiftAnagramsTests.classForKeyedArchiver()).pathForResource("testhits", ofType: "json")
        let data = NSData(contentsOfFile: fileName)
        let json = JSONValue(data)
        
        if let hits = json["hits"].array {
            
            println("\(hits.description)")
            XCTAssert(hits.count == 4, "hit count should be 4, is \(hits.count)")
            let jsonTestHit = hits[0]
            println("\(jsonTestHit.description)")
            
            if let hitID = jsonTestHit["id"].integer {
                println("hit id: \(hitID)")
            }
//            println("we have a test hit with id: \(jsonTestHit["id"].string)")
            let anagram = AnagramPair(json: hits[0])
            println(anagram)
            println(anagram.tweet1.debug_description())
            println(anagram.tweet2.debug_description())
            
//            XCTAssert(anagram.tweet1.text == "And you keep letting me down", "failed to set tweet text")
//            XCTAssert(anagram.tweet2.screenName == "mooanddco", "failed to set screen name")
            XCTAssert(anagram.hitID == 1398833263101, "failed to set hit ID")
        }
        
    }
    
    
}
