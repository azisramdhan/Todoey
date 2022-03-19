//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Azis Ramdhan on 19/03/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let defaults: UserDefaults = UserDefaults.standard

    lazy var context: NSManagedObjectContext = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }()
    
    lazy var categoryArray: [Category] = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let array = try context.fetch(request)
            return array
        } catch {
            print(error)
            return []
        }
    }()
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .categoryCellIdentifier, for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: .goToItemsKey, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController, let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) {
            action in
            guard let text = alertTextField?.text else {
                return
            }
            let category = Category(context: self.context)
            category.name = text
            self.categoryArray.append(category)
            
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
        present(alert, animated: true, completion: nil)
    }
    

}
