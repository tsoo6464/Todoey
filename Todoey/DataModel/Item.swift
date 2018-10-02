//
//  Item.swift
//  Todoey
//
//  Created by Nan on 2018/9/21.
//  Copyright © 2018年 nan. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreate: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
