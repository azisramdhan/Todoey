//
//  Item.swift
//  Todoey
//
//  Created by Azis Ramdhan on 13/03/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

struct Item: Codable {
    let title: String
    var done: Bool = false
}
