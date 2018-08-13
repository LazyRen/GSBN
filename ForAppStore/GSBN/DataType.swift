//
//  DataType.swift
//  GSBN
//
//  Created by Lazy Ren on 10/05/2018.
//  Copyright © 2018 Lazy Ren. All rights reserved.
//

import Foundation

class Train {
    let name : String
    let currentStation: String
    var estimatedArrival : String
    
    init(name: String) {
        self.name = name
        self.currentStation = ""
        self.estimatedArrival = ""
    }
    init(name:String, currentStation: String, estimatedArrival: String) {
        self.name = name
        self.currentStation = currentStation
        self.estimatedArrival = estimatedArrival
    }
}

let nextTrains = NextTrain()

class NextTrain {
    var trains : [Train] = []
    
    init() {
        self.trains = []
        let temp1 = Train(name:"2호선", currentStation:"한양대역", estimatedArrival:"3분")
        let temp2 = Train(name:"5호선", currentStation:"동대문역사문화공원", estimatedArrival:"8분")
        trains += [temp1]
        trains += [temp2]
    }
    func addTrain(temp: Train) {
        trains += [temp]
    }
}
