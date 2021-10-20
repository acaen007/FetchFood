//
//  ViewController.swift
//  FetchFood
//
//  Created by Andy Caen on 10/18/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    
    
    //Initiating variables
    
    private var categoryArray = [Category]()
    private var loading = true
    
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    var categoryPicked = ""
    
    var categoryList: Categories?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchCategories(){ (categories) in
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        //initialize tableView parameters
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        var filteredData = [String]()
        for i in stride(from: 0, to: categoryArray.count, by: 1){
            filteredData.append(categoryArray[i].strCategory)
        }
        let array = (filteredData as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
    //MARK: TABLEVIEW Functions
    
    let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //returns number of rows in section of tableView
    //Section initialized to one since not specified
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Checks if data still loadin
        if loading{
            return 1
        } else{
            //checks whether searchBar function has been activated to filter categories
            if (resultSearchController.isActive) {
                return filteredTableData.count
            } else{
                return categoryArray.count
            }
        }
    }
    
    //Can only update tableView once data has been retrieved, set loading text in the meantime
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if loading{
            cell.textLabel?.text = "Loading..."
        } else {
            if (resultSearchController.isActive) {
                cell.textLabel?.text = filteredTableData[indexPath.row]
                return cell
            }else{
                let text = categoryList?.categories[indexPath.row].strCategory
                cell.textLabel?.text = text
            }
        }
        return cell
    }
    
    //Category is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedCategory = String()
        
        if (resultSearchController.isActive){
            selectedCategory = filteredTableData[indexPath.row]
        } else{
            selectedCategory = (categoryList?.categories[indexPath.row].strCategory)!
        }
        
        categoryPicked = selectedCategory
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Change view to menu for selected category
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? menuView{
            destination.categoryPicked = categoryPicked
        }
    }
    
    //MARK: JSON Parsing
    func fetchCategories(completionHandler: @escaping ([Category]) -> Void) {
        
        // Call the API with dataTask
        //using Decodable Structs to store retrieved JSONs
        //DispatchQueue to populate tableData upon retrieval
        
        if let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        self.categoryList = try JSONDecoder().decode(Categories.self, from: data)
                        completionHandler(self.categoryList!.categories)
                    } catch let error {
                        print(error)
                    }
                    self.categoryArray = self.categoryList!.categories
                }
                self.loading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }.resume()
        }
    }
}

