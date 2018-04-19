//
//  CallDelegate.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-22.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
@objc enum CallEndReason:Int {
    case errorNoUser;
    case errorGeneral;
    case canceled;
    case noAnswer;
    case declined;
    case timeout;
    case hangup;
}
@objc protocol CallDelegate{
    func callDidEnd(reason:String, duration:Double)
    func callDidEstablish()
    func callDidProgress()
    func callDidChangeStatus(status:String)
}
