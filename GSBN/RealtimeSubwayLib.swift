//
//  RealtimeSubwayLib.swift
//  GSBN
//
//  Created by 서창범 on 2018. 5. 18..
//  Copyright © 2018년 Lazy Ren. All rights reserved.
//

import Foundation

//test api url
let urlstr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/realtimePosition/0/50/2호선"

func getRealtimeSubwayPosition () -> Void {
    
    //URL에 한글이 포함되어 URL인코딩을 해야한다.
    guard let encodedUrl = urlstr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
        print("why...")
        return
    }
    
    //디버그용
    print(url)
    
    //request 객체를 만든다.
    var request : URLRequest = URLRequest(url: url)
    request.httpMethod = "GET"
    let session = URLSession.shared
    
    //request 객체로 URLSession dataTask 객체를 만든다. 실질적으로 HTTP request를 보낸다.
    let task = session.dataTask(with: request) { (data, response, error) in
        
        if error != nil {
            print("HTTP Error")
            print(error!)
        } else {
            if let usableData = data {
                do {
                    //parse responed JSON data
                    let jsonSerialized = try JSONSerialization.jsonObject(with: usableData, options: []) as? [String : Any]
                    
                    guard let json = jsonSerialized else {
                        print("parsed JSON referring error")
                        return
                    }
                    
                    //데이터 확인용
                    print(json)
                    
                } catch let error as NSError {
                    print("JSON parsing error.")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    task.resume()
}

//getRealtimeSubwayPosition()
//RunLoop.main.run()
