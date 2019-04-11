//
//  CallParams.swift
//  BlueCall
//
//  Created by Tamara Bernad on 2018-01-16.
//  Copyright © 2018 Blue Call. All rights reserved.
//

import Foundation
class CallParams:NSObject{
    @objc var calleeId: String = "";
    @objc var level:String = "";
    @objc var paymentSourceId:String?;
    @objc var isFirstFreeCall:Bool = false;
}
