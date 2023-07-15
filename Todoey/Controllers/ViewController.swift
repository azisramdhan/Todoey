//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController {
    let realm = try! Realm()
    let defaults: UserDefaults = UserDefaults.standard
    
    lazy var itemArray: [Item] = {
        if let data = defaults.data(forKey: .itemListKey) {
            let decoder = JSONDecoder()
            do {
                let array = try decoder.decode([Item].self, from: data)
                return array
            } catch {
                return []
            }
        } else {
            return []
        }
    }()
    
    var tasks: Results<Task>?
    
    func loadItems() {
        tasks = selectedCategory?.tasks.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return itemArray.count
        } else {
            return tasks?.count ?? .zero
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .itemCellIdentifier, for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = itemArray[indexPath.row].title
            cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        } else {
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.text = tasks?[indexPath.row].title
            cell.accessoryType = tasks?[indexPath.row].done ?? false ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            if let task = tasks?[indexPath.row] {
                do {
                    try realm.write {
                        task.done = !task.done
                        // uncomment for delete action
                        // realm.delete(task)
                        tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            action in
            guard let text = alertTextField?.text else {
                return
            }
            self.itemArray.append(Item(title: text))
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(self.itemArray)
                self.defaults.set(data, forKey: .itemListKey)
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
        
        let taskAction = UIAlertAction(title: "Add Task", style: .default) {
            action in
            guard let text = alertTextField?.text else {
                return
            }
            do {
                try self.realm.write {
                    let task = Task()
                    task.title = text
                    task.dateCreated = Date()
                    self.selectedCategory?.tasks.append(task)
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
        alert.addAction(taskAction)
        present(alert, animated: true, completion: nil)
    }
    

}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            loadItems()
        } else {
            // https://academy.realm.io/posts/nspredicate-cheatsheet/
            tasks = tasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }

        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
