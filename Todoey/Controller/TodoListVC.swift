//
//  ViewController.swift
//  Todoey
//
//  Created by Nan on 2018/8/4.
//  Copyright © 2018年 nan. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListVC: SwipeTableViewController {
    // Variable
    var todoItems: Results<Item>?
    let realm = try! Realm()
    // Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.cellBgColor else { fatalError() }
    
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "#2086FF")
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - TableView Datasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let todoItems = todoItems {
            return todoItems.isEmpty ? 1 : todoItems.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let todoItems = todoItems {
            if let bgcolor = selectedCategory?.cellBgColor {
                
                if todoItems.isEmpty {
                    cell = UITableViewCell()
                    cell.textLabel?.text = "尚未新增項目"
                    tableView.allowsSelection = false
                } else {
                    let item = todoItems[indexPath.row]
                    cell.textLabel?.text = item.title
                    tableView.allowsSelection = true
                    cell.accessoryType = item.done ? .checkmark : .none
                }
                
                cell.backgroundColor = UIColor(hexString: bgcolor)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count))
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            }
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //點擊cell的動畫 不會讓選中的cell一直呈現灰色
        tableView.deselectRow(at: indexPath, animated: true)
        if todoItems?.isEmpty == false {
            if let item = todoItems?[indexPath.row] {
                do {
                    try realm.write {
                        item.done = !item.done
                    }
                } catch {
                    print("Error saving done status. \(error)")
                }
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert  = UIAlertController(title: "新增待辦事項", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "新增", style: .default) { (action) in
            //添加事件功能
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textfield.text!
                        newItem.dateCreate = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "新增事項"
            textfield = alertTextfield
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Model Manipulation Methods
    // = 是給傳入參數一個預設值 若呼叫方法時未加上參數 則使用預設值
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreate", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
}

//MARK: - Search bar methods
extension TodoListVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreate", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                // 取消searchBar為當前操作
                searchBar.resignFirstResponder()
            }
        }
    }
}

