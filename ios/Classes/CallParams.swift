//
//  CallParams.swift
//  BlueCall
//
//  Created by Tamara Bernad on 2018-01-16.
//  Copyright © 2018 Blue Call. All rights reserved.
//

import Foundation
class CallParams:NSObject{
    var calleeId: String = "";
    var level:String = "";
    var paymentSourceId:String?;
    var isFirstFreeCall:Bool = false;
}
