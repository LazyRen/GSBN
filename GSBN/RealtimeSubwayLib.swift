//
//  RealtimeSubwayLib.swift
//  GSBN
//
//  Created by 서창범 on 2018. 5. 18..
//  Copyright © 2018년 Lazy Ren. All rights reserved.
//

import Foundation

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
    var recptnDt : Date = Date()  // 2018-05-18 16:47:55      //당장은 스트링으로 하는데 추후 타임스탬프로 구현. 그래야 시간 연산 용이. 수신된 시간
    var statnId : Int = 0       // 1002000238 //지하철 역 아이디
    var subwayNm : String = ""  // 2호선       //지하철 호선명
    
    init (parsedData : [String:Any]) {
        if let fetchedtrainNoStr = parsedData["trainNo"] as? String, let fetchedtrainNoInt = Int(fetchedtrainNoStr) {
            self.trainNo = fetchedtrainNoInt
        }
        
        if let fetchedstatnTidStr = parsedData["statnTid"] as? String, let fetchedstatnTidInt = Int(fetchedstatnTidStr) {
            self.statnTid = fetchedstatnTidInt
        }
        
        if let fetchedstatnNm = parsedData["statnNm"] as? String {
            self.statnNm = fetchedstatnNm
        }
        
        if let fetchedtrainSttusStr = parsedData["trainSttus"] as? String, let fetchedtrainSttusInt = Int(fetchedtrainSttusStr) {
            self.trainSttus = fetchedtrainSttusInt
        }
        
        if let fetchedtrainSttusStr = parsedData["directAt"] as? String, let fetchedtrainSttusInt = Int(fetchedtrainSttusStr) {
            self.directAt = fetchedtrainSttusInt
        }
        
        if let fetchedlastRecptnDtStr = parsedData["lastRecptnDt"] as? String, let fetchedlastRecptnDtInt = Int(fetchedlastRecptnDtStr) {
            self.lastRecptnDt = fetchedlastRecptnDtInt
        }
        
        if let fetchedstatnTnm = parsedData["statnTnm"] as? String {
            self.statnTnm = fetchedstatnTnm
        }
        
        if let fetchedsubwayIdStr = parsedData["subwayId"] as? String, let fetchedsubwayIdInt = Int(fetchedsubwayIdStr) {
            self.subwayId = fetchedsubwayIdInt
        }
        
        if let fetchedupdnLineStr = parsedData["updnLine"] as? String, let fetchedupdnLineInt = Int(fetchedupdnLineStr) {
            self.updnLine = fetchedupdnLineInt
        }
        
        if let fetchedlstcarAtStr = parsedData["lstcarAt"] as? String, let fetchedlstcarAtInt = Int(fetchedlstcarAtStr) {
            self.lstcarAt = fetchedlstcarAtInt
        }
        
        if let fetchedrecptnDt = parsedData["recptnDt"] as? String {  //당장은 스트링으로 하는데 추후 타임스탬프로 구현. 그래야 시간 연산 용이
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let time = formatter.date(from: fetchedrecptnDt) {
                self.recptnDt = time
            }
        }
        
        if let fetchedstatnIdStr = parsedData["statnId"] as? String, let fetchedstatnIdInt = Int(fetchedstatnIdStr) {
            self.statnId = fetchedstatnIdInt
        }
        
        if let fetchedsubwayNm = parsedData["subwayNm"] as? String {
            self.subwayNm = fetchedsubwayNm
        }
    }
}

struct stations {
    var lineSet : Set<String> = []
    var stationList : Array<String> = []
    
    init (parsedData : [[String:Any]]) {
        lineSet = []
        stationList = []
        
        for station in parsedData {
            if let stationName = station["statnNm"] as? String {
                if !stationList.contains(stationName) {
                    stationList.append(stationName)
                }
            }
            
            if let lineName = station["subwayNm"] as? String {
                lineSet.insert(lineName)
            }
            
        }
        return
    }
}

class RealtimeSubwayPositions {
    var positionList : [realtimeSubwayPositionListEntry] = []
    let apistr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/realtimePosition/0/50/"
    var line = ""
    
    init(whichLine : String) {
        line = whichLine;
        
        // updateRealtimeSubwayPosition() 뒤에 클로져를 붙이면 completionHandler가 호출 될 때 실행됨. 이 클로져 == completionHandler임
        self.getRealtimeSubwayPosition() { updatedPositionList in
            self.positionList = updatedPositionList
            updatedPositionList.map {
                print($0.subwayNm, $0.statnNm, $0.statnTnm,
                      $0.updnLine == 1 ? "내선순환" : "외선순환",
                      $0.lstcarAt == 1 ? "막차" : "막차 ㄴㄴ",
                      $0.recptnDt.description(with: Locale(identifier: "ko_KR")))
            }
        }
    }
    
    /* 실시간 지하철 위치정보 API에 HTTP request를 보내서 실시간 지하철 위치정보를 담은 object를 받아옴. */
    func getRealtimeSubwayPosition (completionHandler: @escaping (_ updatedPositionList : [realtimeSubwayPositionListEntry]) -> Void) -> Void {
        
        //URL에 한글이 포함되어 URL인코딩을 해야한다.
        guard let encodedUrl = (apistr + line).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
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
                        
                        //api 서버가 죽는 경우가 많아서 에러가 났을 때 HTTP 코드를 볼 수 있도록 하는 코드 추가
                        if let httpResponse = response as? HTTPURLResponse {
                            print(httpResponse.statusCode)
                        }
                        
                    }
                }
            }
        }
        
        task.resume()
    }
}


class RealtimeSubwayNearestStations {
    let convert : GeoConverter
    var currentPosition : GeographicPoint
    let apistr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/nearBy/0/5/"
    
    init(WGS_N : Double, WGS_E : Double) {
        convert = GeoConverter()
        currentPosition = GeographicPoint(x: WGS_N, y: WGS_E)
        if let TmPosition = convert.convert(sourceType: .WGS_84, destinationType: .TM, geoPoint: currentPosition) {
            currentPosition = TmPosition
            print(TmPosition)
        }
        return
    }
    
    /* 실시간 지하철 위치정보 API에 HTTP request를 보내서 실시간 지하철 위치정보를 담은 object를 받아옴. */
    func getNearestStations () -> Void {
        
        //URL에 한글이 포함되어 URL인코딩을 해야한다.
        guard let encodedUrl = (apistr + String(currentPosition.x) + "/" + String(currentPosition.y)).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
            print("why...")
            return
        }
        
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
                        
                        print(json)
                        
                    } catch let error as NSError {
                        print("JSON parsing error.")
                        print(error.localizedDescription)
                        
                        //api 서버가 죽는 경우가 많아서 에러가 났을 때 HTTP 코드를 볼 수 있도록 하는 코드 추가
                        if let httpResponse = response as? HTTPURLResponse {
                            print(httpResponse.statusCode)
                        }
                        
                    }
                }
                
            }
        }
        
        task.resume()
    }
}


//test code 플레이 그라운드에서 실행해보면됨
//let line2 = RealtimeSubwayPositions.init(whichLine : "2호선")
//let nearlistStation = RealtimeSubwayNearestStations.init(WGS_N: 127.037194, WGS_E: 37.561750)
//nearlistStation.getNearestStations()
//RunLoop.main.run()
