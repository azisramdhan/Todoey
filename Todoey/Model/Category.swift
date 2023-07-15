//
//  Category.swift
//  Todoey
//
//  Created by Azis Ramdhan on 15/07/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    var tasks = List<Task>()
}
