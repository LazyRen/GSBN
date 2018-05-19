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

struct realtimeSubwayPositionListEntry {
    var trainNo : Int = 0       // 2300       // 열차번호
    var statnTid : Int = 0      // 1002000211 // 종착지하철역아이디
    var statnNm : String = ""   // 합정        // 지하철역이름
    var trainSttus : Int = 0    // 2          // 0 : 진입, 1 : 도착, 2 : 그외 상태
    var directAt : Int = 0      // 0          // 급행여부
    var lastRecptnDt : Int = 0  // 20180518   // 최종수신날짜
    var statnTnm : String = ""  // 성수종착     // 종착역이름
    var subwayId : Int = 0      // 1002       // 지하철 호선 ID
    var updnLine : Int = 0      // 0          // 0 : 상행(외선) 1 : 하행(내선)
    var lstcarAt : Int = 0      // 0          // 막차여부
    var recptnDt : String = ""  // 2018-05-18 16:47:55      //당장은 스트링으로 하는데 추후 타임스탬프로 구현. 그래야 시간 연산 용이. 수신된 시간
    var statnId : Int = 0       // 1002000238 //지하철 역 아이디
    var subwayNm : String = ""  // 2호선       //지하철 호선명
    
    init (parsedData : [String:Any]) {
        if let fetchedtrainNo = parsedData["trainNo"] as? Int {
            self.trainNo = fetchedtrainNo
        }
        
        if let fetchedstatnTid = parsedData["statnTid"] as? Int {
            self.statnTid = fetchedstatnTid
        }
        
        if let fetchedstatnNm = parsedData["statnNm"] as? String {
            self.statnNm = fetchedstatnNm
        }
        
        if let fetchedtrainSttus = parsedData["trainSttus"] as? Int {
            self.trainSttus = fetchedtrainSttus
        }
        
        if let fetchedtrainSttus = parsedData["directAt"] as? Int {
            self.directAt = fetchedtrainSttus
        }
        
        if let fetchedlastRecptnDt = parsedData["lastRecptnDt"] as? Int {
            self.lastRecptnDt = fetchedlastRecptnDt
        }
        
        if let fetchedstatnTnm = parsedData["statnTnm"] as? String {
            self.statnTnm = fetchedstatnTnm
        }
        
        if let fetchedsubwayId = parsedData["subwayId"] as? Int {
            self.subwayId = fetchedsubwayId
        }
        
        if let fetchedupdnLine = parsedData["updnLine"] as? Int {
            self.updnLine = fetchedupdnLine
        }
        
        if let fetchedlstcarAt = parsedData["lstcarAt"] as? Int {
            self.lstcarAt = fetchedlstcarAt
        }
        
        if let fetchedrecptnDt = parsedData["recptnDt"] as? String {  //당장은 스트링으로 하는데 추후 타임스탬프로 구현. 그래야 시간 연산 용이
            self.recptnDt = fetchedrecptnDt
        }
        
        if let fetchedstatnId = parsedData["statnId"] as? Int {
            self.statnId = fetchedstatnId
        }
        
        if let fetchedsubwayNm = parsedData["subwayNm"] as? String {
            self.subwayNm = fetchedsubwayNm
        }
    }
}

class RealtimeSubwayPositions {
    var positionList : [realtimeSubwayPositionListEntry] = []
    
    init() {
        // updateRealtimeSubwayPosition() 뒤에 클로져를 붙이면 completionHandler가 호출 될 때 실행됨. 이 클로져 == completionHandler임
        self.getRealtimeSubwayPosition() { updatedPositionList in
            self.positionList = updatedPositionList
            print(updatedPositionList)
        }
    }
    
    /* 실시간 지하철 위치정보 API에 HTTP request를 보내서 실시간 지하철 위치정보를 담은 object를 받아옴. */
    func getRealtimeSubwayPosition (completionHandler: @escaping (_ updatedPositionList : [realtimeSubwayPositionListEntry]) -> Void) -> Void {
        
        //URL에 한글이 포함되어 URL인코딩을 해야한다.
        guard let encodedUrl = urlstr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
            print("why...")
            return
        }
        
        //request 객체를 만든다.
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        //request 객체로 URLSession dataTask 객체를 만든다. 실질적으로 HTTP request를 보낸다.
        let task = session.dataTask(with: request) { (data, response, error) in
            
            var PositionListToUpdate : [realtimeSubwayPositionListEntry] = []
            
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
                        
                        guard let fetchedRealtimePositionList = json["realtimePositionList"] as? [[String:Any]] else {
                            print("parsed JSON referring error")
                            return
                        }
                        
                        for entry in fetchedRealtimePositionList {
                            PositionListToUpdate.append(realtimeSubwayPositionListEntry.init(parsedData: entry))
                        }
                        
                        // 핵심 : callback함수임.
                        // 여기서 직접적으로 return한다고 넘기고자 하는 object가 안넘어감 ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ
                        completionHandler(PositionListToUpdate)
                        
                    } catch let error as NSError {
                        print("JSON parsing error.")
                        print(error.localizedDescription)
                        
                    }
                }
            }
        }
        
        task.resume()
    }
}



//let line2 = RealtimeSubwayPositions.init()
//RunLoop.main.run()
