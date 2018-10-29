//
//  Category.swift
//  Todoey
//
//  Created by Nan on 2018/9/21.
//  Copyright © 2018年 nan. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellBgColor: String = ""
    let items = List<Item>()
}
