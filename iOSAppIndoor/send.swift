//
//  send.swift
//  test
//
//  Created by mwnl on 2019/8/26.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//Function to send packet to Server.
public func sendDataToServer(proto: Data)->Result{
    switch CountryServer.send(data: proto){
    case.success:
        return .success
    case .failure(let error):
        return .failure(SocketError.unknownError)
    }
}
