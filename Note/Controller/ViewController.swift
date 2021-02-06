//
//  ViewController.swift
//  Note
//
//  Created by Fatma on 04/02/2021.
//

//add date with note
//when click on note present note and date 
import UIKit
import RealmSwift
import ChameleonFramework
import SwipeCellKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadCategory()
        tableView.separatorStyle = .none
       
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist") }
        
        navBar.backgroundColor = UIColor(hexString: "#bedcfa") //chameleon
    }

    
    //MARK: - TableView DataSource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
    
    cell.delegate = self
    
    if let category = categories?[indexPath.row]{
        guard let categoryColor = UIColor(hexString: category.backgroundColor) else {
            fatalError()
        }
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Not categories"
        
        cell.backgroundColor = categoryColor
        
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
    }
    
    return cell
    
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathsForSelectedRows {
            destination.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - SwipeTableViewCellDelegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            //update model
            
            if let categoryForDeletion = self.categories?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("error deleting category \(error)")
            }
                
               // tableView.reloadData()
        }
            
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var option = SwipeOptions()
        option.expansionStyle = .destructive
        return option
    }
    
    //MARK: - Add New Categories
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = UIColor.randomFlat().hexValue()
            
            self.saveCategory(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data manipulation method
    
    func saveCategory(category: Category){
        do{
            try realm.write{ //new catwgpry //commit to reaml
                realm.add(category) //add to realm
            }
        }catch{
            print("error saving context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategory(){
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}

