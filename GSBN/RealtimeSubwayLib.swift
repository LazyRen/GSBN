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
    var stationOrderList : [String] = []
    var stationList : [String : [(lineName : String, lineId : Int)]] = [:]
    
    init (parsedData : [[String:Any]]) {
        lineSet = []
        stationList = [:]
        
        for station in parsedData {
            if let stationName = station["statnNm"] as? String,
                let lineName = station["subwayNm"] as? String,
                let fetchedlineId = station["subwayId"] as? String,
                let lineId = Int(fetchedlineId) {
                
                if stationList[stationName] == nil {
                    stationList[stationName] = []
                }
                
                stationList[stationName]?.append((lineName, lineId))
                
                if !stationOrderList.contains(stationName) {
                    stationOrderList.append(stationName)
                }
            }
            
            if let lineName = station["subwayNm"] as? String {
                lineSet.insert(lineName)
            }
            
        }
        return
    }
    
    init() {
        lineSet = []
        stationList = [:]
        stationOrderList = []
    }
}

struct arrivalInfoEntry {
    var stationId : Int = 0          //기준 지하철 역 ID
    var stationName : String = ""    //기준 지하철 역 이름
    var lineId : Int = 0             //지하철 호선 ID
    //var lineName : String            //지하철 호선 이름
    var updownFlag : Int = 0         //상하행 구분  // 0 : 상행(외선) 1 : 하행(내선)
    var updownMsg : String = ""      //상하행 구분 str
    
    var terminusId : Int = 0         //종착 지하철역 ID
    var terminusName : String = ""   //종착 지하철역 이름 (막차 정보 포함)
    var directionInfo : String = ""  //종착역 + 방면 (막차 정보 포함)
    var expressFlag : Int = 0        //급행여부
    var lastFlag : Int = 0           //막차여부
    var trainId : Int = 0            //해당 열차 ID
    var curStationId : Int = 0       //해당 열차 위치한 역 ID
    var curStationName : String = "" //해당 열차 위치한 역 이름
    
    var arrivalCode : Int = 0        //도착코드
    var arrivalMsg : String = ""     //도착코드 메세지
    var leftTime : Int = 0           //열차 도착 예정시간 (남은시간 초)
    var leftTimeMsg : String = ""    //도착 예정시간 메세지
    
    init(parsedData : [String : Any]) {
        if let fetchedStationName = parsedData["statnNm"] as? String {
            stationName = fetchedStationName
        }
        
        //lineName = whichLine
        
        if let fetchedTerminusName = parsedData["bstatnNm"] as? String {
            terminusName = fetchedTerminusName
        }
        
        if let fetchedDiretionInfo = parsedData["trainLineNm"] as? String {
            directionInfo = fetchedDiretionInfo
            if fetchedDiretionInfo.contains("막차") {
                lastFlag = 1
            }
        }
        
        if let fetchedCurStationName = parsedData["arvlMsg3"] as? String {
            curStationName = fetchedCurStationName
        }
        
        if let fetchedArrivalMsg = parsedData["arvlMsg2"] as? String {
            arrivalMsg = fetchedArrivalMsg
        }
        
        if let fetchedStationId = parsedData["statnId"] as? String, let fetchedStationIdInt = Int(fetchedStationId) {
            stationId = fetchedStationIdInt
        }
        
        if let fetchedLineId = parsedData["subwayId"] as? String, let fetchedLineIdInt = Int(fetchedLineId) {
            lineId = fetchedLineIdInt
        }
        
        if let fetchedUpdownFlag = parsedData["updnLine"] as? String {
            updownMsg = fetchedUpdownFlag
            if fetchedUpdownFlag == "하행" || fetchedUpdownFlag == "내선" {
                updownFlag = 1
            }
        }
        
        if let fetchedTerminusId = parsedData["bstatnId"] as? String, let fetchedTerminusIdInt = Int(fetchedTerminusId) {
            terminusId = fetchedTerminusIdInt
        }
        
        if let fetchedExpressFlag = parsedData["btrainSttus"] as? String {
            if fetchedExpressFlag == "급행" {
                expressFlag = 1
            }
        }
        
        if let fetchedTrainId = parsedData["btrainNo"] as? String, let fetchedTrainIdInt = Int(fetchedTrainId) {
            trainId = fetchedTrainIdInt
        }
        
        if let fetchedCurStationId = parsedData["bstatnId"] as? String, let fetchedCurStationIdInt = Int(fetchedCurStationId) {
            curStationId = fetchedCurStationIdInt
        }
        
        if let fetchedArrivalCode = parsedData["arvlCd"] as? String, let fetchedArrivalCodeInt = Int(fetchedArrivalCode) {
            arrivalCode = fetchedArrivalCodeInt
        }
        
        if let fetchedLeftTime = parsedData["barvlDt"] as? String, let fetchedLeftTimeInt = Int(fetchedLeftTime) {
            leftTime = fetchedLeftTimeInt
        }
        
        if let fetchedLeftTimeMsg = parsedData["arvlMsg2"] as? String {
            leftTimeMsg = fetchedLeftTimeMsg
        }
        
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
                        self.positionList = PositionListToUpdate
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
    var stationInfo : stations = stations.init()
    let convert : GeoConverter
    var currentPosition : GeographicPoint
    let apistr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/nearBy/0/20/"
    
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
    func getNearestStations (completionHandler: @escaping (_ updatedStationInfo : stations) -> Void) -> Void {
        
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
            
            var stationsToUpdate : stations
            
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
                        
                        guard let fetchedStationList = json["stationList"] as? [[String:Any]] else {
                            print("parsed JSON referring error")
                            
                            return
                        }
                        
                        stationsToUpdate = stations(parsedData: fetchedStationList)
                        self.stationInfo = stationsToUpdate
                        completionHandler(stationsToUpdate)
                        
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

class realtimeSubwayArrivalInfo {
    var arrivalInfo : [String : [Int : [arrivalInfoEntry]]] = [:] // 예시 : arrivalInfo["2호선"][0 (외선)][0]
    var stationName : String = "" // 예시 : 왕십리
    var lineList : [(lineName : String, lineId : Int)] = []
    let apistr = "http://swopenapi.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/realtimeStationArrival/0/30/"
    
    init(stationName : String, lineInfoList : [(lineName : String, lineId : Int)]) {
        self.stationName = stationName
        self.lineList = lineInfoList
        return
    }
    
    /* 실시간 지하철 위치정보 API에 HTTP request를 보내서 실시간 지하철 위치정보를 담은 object를 받아옴. */
    func getArrivalInfo (completionHandler: @escaping (_ updatedStationInfo : [String : [Int : [arrivalInfoEntry]]]) -> Void) -> Void {
        
        //URL에 한글이 포함되어 URL인코딩을 해야한다.
        guard let encodedUrl = (apistr + self.stationName).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
            print("why...")
            
            return
        }
        
        //request 객체를 만든다.
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        //request 객체로 URLSession dataTask 객체를 만든다. 실질적으로 HTTP request를 보낸다.
        let task = session.dataTask(with: request) { (data, response, error) in
            var arrivalInfoEntryListToUpdate : [arrivalInfoEntry] = []
            var arrivalInfoToUpdate : [String : [Int : [arrivalInfoEntry]]] = [:]
            
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
                        
                        guard let fetchedArrivalList = json["realtimeArrivalList"] as? [[String:Any]] else {
                            print("parsed JSON referring error")
                            
                            return
                        }
                        
                        for entry in fetchedArrivalList {
                            arrivalInfoEntryListToUpdate.append(arrivalInfoEntry.init(parsedData: entry))
                        }
                        
                        self.lineList.map({ (lineInfo) -> Void in
                            if arrivalInfoToUpdate[lineInfo.lineName] == nil {
                                arrivalInfoToUpdate[lineInfo.lineName] = [:]
                            }
                            arrivalInfoToUpdate[lineInfo.lineName]![0] = arrivalInfoEntryListToUpdate.filter({ $0.lineId == lineInfo.lineId && $0.updownFlag == 0 })
                            arrivalInfoToUpdate[lineInfo.lineName]![1] = arrivalInfoEntryListToUpdate.filter({ $0.lineId == lineInfo.lineId && $0.updownFlag == 1 })
                        })
                        
                        self.arrivalInfo = arrivalInfoToUpdate
                        completionHandler(arrivalInfoToUpdate)
                        
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

//사용 예시
/*
 /* RealtimeSubwayNearestStations 클래스에 현재 좌표를 입력하고 초기화를 한다. */
 let nearestStation = RealtimeSubwayNearestStations.init(WGS_N: 127.041773, WGS_E: 37.560591)
 
 /* getNearestStations 메소드를 호출하여 completionhandler에 인자로 stations 구조체에 인접 지하철 정보를 받아온다 */
 nearestStation.getNearestStations { (fetchedStations) in
 /* nearestStation.stationInfo.stationOrderList[0] 에는 가장 우선순위가 높은 지하철역 이름이 저장돼있다
 해당 지하철역에 지나는 호선들과 호선들의 고유번호가 저장돼있는 정보를 가져온다.*/
 if let stationInfo = fetchedStations.stationList[nearestStation.stationInfo.stationOrderList[1]] {
 // realtimeSubwayArrivalInfo 에 도착정보를 가져올 역이름과 해당 역에 지나는 호선 정보를 넘겨 초기화한다.
 let curArrivalInfo = realtimeSubwayArrivalInfo.init(stationName: fetchedStations.stationOrderList[1], lineInfoList: stationInfo)
 // 초기화된 정보를 가지고 도착정보를 가져온다.
 curArrivalInfo.getArrivalInfo(completionHandler: { (fetchedArrivalInfo) in
 fetchedArrivalInfo.keys.map({ (line) -> Void in
 fetchedArrivalInfo[line]?.keys.map({ (updownFlag) -> Void in
 if let entrys = fetchedArrivalInfo[line]?[updownFlag] {
 entrys.map({ (entry) -> Void in
 print(line, entry.stationName, entry.directionInfo, entry.curStationName, entry.leftTimeMsg, String(entry.leftTime) + "초 후 도착")
 })
 }
 })
 })
 })
 }
 }
 
 
 RunLoop.main.run()
 */
