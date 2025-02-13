//
//  LoginResult.swift
//  With
//
//  Created by 남수김 on 2019/12/30.
//  Copyright © 2019 ns. All rights reserved.
//

import Foundation

struct LoginResult: Codable {
    var success: Bool
    var message: String
    var data: LoginData?
    
    struct LoginData: Codable {
        var token: String
        var userIdx: Int
    }
}
