//
//  User.swift
//  CloneSignIn
//
//  Created by macOS on 6/1/20.
//  Copyright © 2020 macOS. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object{
    @objc dynamic var name:String?
    @objc dynamic var phoneNumber:String?
}
