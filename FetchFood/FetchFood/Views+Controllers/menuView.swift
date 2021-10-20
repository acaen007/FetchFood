//
//  menuView.swift
//  FetchFood
//
//  Created by Andy Caen on 10/19/21.
//

import UIKit

class menuView : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    private var mealArray = [Meal]()
    private var loading = true
    
    var categoryPicked: String = ""
    var recipePicked = ""
    
    
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    var mealList: Meals?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        fetchMeals(category: categoryPicked){ (meals) in
            
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        view.addSubview(tableView)
        //tableView.backgroundColor = #colorLiteral(red: 0.8971737027, green: 0.6403112411, blue: 0.6935434937, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    //Filters through meals based on searchBar lookup
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        var filteredData = [String]()
        for i in stride(from: 0, to: mealArray.count, by: 1){
            filteredData.append(mealArray[i].strMeal)
        }
        let array = (filteredData as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
    //MARK: TableView functions
    
    let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading{
            return 1
        } else{
            if (resultSearchController.isActive) {
                return filteredTableData.count
            }else{
                return mealArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if loading{
            cell.textLabel?.text = "Loading..."
        } else {
            if (resultSearchController.isActive){
                cell.textLabel?.text = filteredTableData[indexPath.row]
                return cell
            } else{
                let text = mealList?.meals[indexPath.row].strMeal
                cell.textLabel?.text = text
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedMeal = String()
        
        //need to pass on the id rather than the name
        if (resultSearchController.isActive){
            let dishName = (filteredTableData[indexPath.row])
            for meal in mealList!.meals{
                if meal.strMeal == dishName{
                    selectedMeal = meal.idMeal
                }
            }
        } else{
            selectedMeal = (mealList?.meals[indexPath.row].idMeal)!
        }
        recipePicked = selectedMeal
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        performSegue(withIdentifier: "recipeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? recipeView{
            destination.recipeID = recipePicked
        }
    }
    
    func fetchMeals(category: String, completionHandler: @escaping ([Meal]) -> Void) {
        
        // Call the API passing category string in url
        
        if let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        self.mealList = try JSONDecoder().decode(Meals.self, from: data)
                        completionHandler(self.mealList!.meals)
                    } catch let error {
                        print(error)
                    }
                    self.mealArray = self.mealList!.meals
                }
                self.loading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }.resume()
        }
    }
    
}



