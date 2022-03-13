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
    
    lazy var taskArray: [Task] = {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let array = try context.fetch(request)
            return array
        } catch {
            print(error)
            return []
        }
    }()

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

