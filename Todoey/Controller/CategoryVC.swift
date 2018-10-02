//
//  CategoryVC.swift
//  Todoey
//
//  Created by Nan on 2018/8/24.
//  Copyright © 2018年 nan. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryVC: UITableViewController {
    
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
        
        let action = UIAlertAction(title: "新增", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "新增分類"
            textField = alertTextfield
        }
        
        alert.addAction(action)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        if let category = categoryArray {
            cell.textLabel?.text = category.isEmpty ? "尚未新增分類" : category[indexPath.row].name
        }
        
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
}
