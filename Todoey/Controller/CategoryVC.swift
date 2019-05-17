//
//  CategoryVC.swift
//  Todoey
//
//  Created by Nan on 2018/8/24.
//  Copyright © 2018年 nan. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryVC: SwipeTableViewController {
    // Variable
    let realm = try! Realm()
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: - Add New Categories
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "新增分類", message: "", preferredStyle: .alert)
        
        let cancelAtion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "新增", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellBgColor = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "新增分類"
            textField = alertTextfield
        }
        
        alert.addAction(action)
        alert.addAction(cancelAtion)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = categoryArray {
            return category.isEmpty ? 1 : category.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        var cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray {
            // 沒創建分類 建立的是一般的cell 不能進行刪除事件
            if category.isEmpty {
                cell = UITableViewCell()
            }
            cell.textLabel?.text = category.isEmpty ? "尚未新增分類" : category[indexPath.row].name
            cell.backgroundColor = category.isEmpty ? UIColor(hexString: "#2086FF") : UIColor(hexString: category[indexPath.row].cellBgColor)
            // 沒創建分類時不能點擊cell
            tableView.allowsSelection = category.isEmpty ? false : true
            
            cell.textLabel?.textColor = category.isEmpty ? UIColor.white : ContrastColorOf(UIColor(hexString: category[indexPath.row].cellBgColor)!, returnFlat: true)
        }
        
        //cell.delegate = self
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let category = categoryArray {
            if !category.isEmpty {
                performSegue(withIdentifier: "goToItem", sender: self)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    // 傳過去TodoListVC選擇到的分類值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    //讀取分類
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}
