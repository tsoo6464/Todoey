//
//  ViewController.swift
//  Todoey
//
//  Created by Nan on 2018/8/4.
//  Copyright © 2018年 nan. All rights reserved.
//

import UIKit

class TodoListVC: UITableViewController {
    
    var itemArray = [Item]()//["Find Mike", "Buy Eggos", "Destory Demogorgon"]
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item1 = Item()
        item1.title = "Find Mike"
        itemArray.append(item1)
        
        let item2 = Item()
        item2.title = "Buy Eggos"
        itemArray.append(item2)
        
        let item3 = Item()
        item3.title = "Destory Demogorgon"
        itemArray.append(item3)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //點擊cell的動畫 不會讓選中的cell一直呈現灰色
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.reloadData()
    }
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert  = UIAlertController(title: "新增待辦事項", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "新增", style: .default) { (action) in
            //添加事件功能
            let newItem = Item()
            newItem.title = textfield.text!
            self.itemArray.append(newItem)
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "新增事項"
            textfield = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

