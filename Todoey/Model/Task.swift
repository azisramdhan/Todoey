//
//  Task.swift
//  Todoey
//
//  Created by Azis Ramdhan on 15/07/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
}
