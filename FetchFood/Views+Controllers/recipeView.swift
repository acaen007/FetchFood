//
//  recipeView.swift
//  FetchFood
//
//  Created by Andy Caen on 10/19/21.
//

import UIKit

class recipeView : UIViewController{
    
    
    private var loading = true
    
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var dishImage: UIImageView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var index = 0
    
    var ingredients = [String]()
    var measurements = [String]()
    
    var recipeID: String = ""
    
    var recipe: Recipe?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecipe(id: recipeID) { (recipe) in
            
        }
    }
    
    
    
    func fetchRecipe(id: String, completionHandler: @escaping ([RecipeInfo]) -> Void) {
        
        // Call the API with some code
        
        if let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        self.recipe = try JSONDecoder().decode(Recipe.self, from: data)
                        
                        completionHandler(self.recipe!.meals)
                    } catch let error {
                        print(error)
                    }
                }
                self.loading = false
                DispatchQueue.main.async {
                    //Display final UI
                    self.recipeNameLabel.text = self.recipe?.meals[0].strMeal
                    self.fetchImage(url: URL(string: (self.recipe?.meals[0].strMealThumb)!)!)
                    self.getIngredients(meal: self.recipe!)
                    self.getMeasurements(meal: self.recipe!)
                    self.instructionsLabel.text = self.recipe!.meals[0].strInstructions
                    
                    while self.index < self.ingredients.count{
                        self.ingredientsLabel.text?.append(self.ingredients[self.index] + " : " + self.measurements[self.index] + "\n")
                        self.index+=1
                    }
                }
            }.resume()
        }
        
    }
    
    //Removes all nil and space values and keeps only populated data
    func getIngredients(meal: Recipe){
        ingredients = [meal.meals[0].strIngredient1 ?? "",meal.meals[0].strIngredient2 ?? "",meal.meals[0].strIngredient3 ?? "",meal.meals[0].strIngredient4 ?? "",meal.meals[0].strIngredient5 ?? "",meal.meals[0].strIngredient6 ?? "",meal.meals[0].strIngredient7 ?? "",meal.meals[0].strIngredient8 ?? "",meal.meals[0].strIngredient9 ?? "",meal.meals[0].strIngredient10 ?? "",meal.meals[0].strIngredient11 ?? "",meal.meals[0].strIngredient12 ?? "",meal.meals[0].strIngredient13 ?? "",meal.meals[0].strIngredient14 ?? "",meal.meals[0].strIngredient15 ?? "",meal.meals[0].strIngredient16 ?? "",meal.meals[0].strIngredient17 ?? "",meal.meals[0].strIngredient18 ?? "",meal.meals[0].strIngredient19 ?? "",meal.meals[0].strIngredient20 ?? ""]
        ingredients.removeAll{($0 == "" || $0 == " ")}
    }
    
    //Removes all nil and space values and keeps only populated data
    func getMeasurements(meal: Recipe){
        measurements = [meal.meals[0].strMeasure1 ?? "",meal.meals[0].strMeasure2 ?? "",meal.meals[0].strMeasure3 ?? "",meal.meals[0].strMeasure4 ?? "",meal.meals[0].strMeasure5 ?? "",meal.meals[0].strMeasure6 ?? "",meal.meals[0].strMeasure7 ?? "",meal.meals[0].strMeasure8 ?? "",meal.meals[0].strMeasure9 ?? "",meal.meals[0].strMeasure10 ?? "",meal.meals[0].strMeasure11 ?? "",meal.meals[0].strMeasure12 ?? "",meal.meals[0].strMeasure13 ?? "",meal.meals[0].strMeasure14 ?? "",meal.meals[0].strMeasure15 ?? "",meal.meals[0].strMeasure16 ?? "",meal.meals[0].strMeasure17 ?? "",meal.meals[0].strMeasure18 ?? "",meal.meals[0].strMeasure19 ?? "",meal.meals[0].strMeasure20 ?? ""]
        measurements.removeAll{($0 == "" || $0 == " ")}
    }
    
    //retrieve meal image
    func fetchImage(url: URL){
        URLSession.shared.dataTask(with: url){data,response,error in
            guard let data = data, error == nil else { return }
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.dishImage.image = UIImage(data: data)
            }
        }.resume()
    }
}
