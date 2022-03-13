//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .itemCellIdentifier, for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .none)
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
        
        alert.addTextField() {
            textField in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

}

