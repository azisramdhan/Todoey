//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Azis Ramdhan on 19/03/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category> {
        let categories = realm.objects(Category.self)
        return categories
    }
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .categoryCellIdentifier, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .goToItemsKey, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController, let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] action in
            guard let self,
                  let text = alertTextField?.text else {
                return
            }
            let category = Category()
            category.name = text            
            do {
                try self.realm.write { [weak self] in
                    guard let self else { return }
                    self.realm.add(category)
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        
        alert.addTextField() {
            textField in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

}
