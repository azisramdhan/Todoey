//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    let defaults: UserDefaults = UserDefaults.standard

    lazy var context: NSManagedObjectContext = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }()
    
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
    
    var additionalPredicate: NSPredicate?
    
    var taskArray: [Task] = []
    
    func loadItems() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        if let additionalPredicate = additionalPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, additionalPredicate])
            self.additionalPredicate = nil
        } else {
            request.predicate = predicate
        }
        
        do {
            taskArray = try context.fetch(request)
        } catch {
            print(error)
            taskArray = []
        }
        
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
            return 0
        } else {
            return taskArray.count
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
            cell.textLabel?.text = taskArray[indexPath.row].title
            cell.accessoryType = taskArray[indexPath.row].done ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            context.delete(taskArray[indexPath.row])
            taskArray.remove(at: indexPath.row)
            do {
                try context.save()
            } catch {
                print(error)
            }
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
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
            let task = Task(context: self.context)
            task.title = text
            task.parentCategory = self.selectedCategory
            self.taskArray.append(task)
            
            do {
                try self.context.save()
                self.tableView.reloadData()
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
            additionalPredicate = nil
            loadItems()
        } else {
            additionalPredicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
            loadItems()
        }

        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            additionalPredicate = nil
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
