//
//  FilterViewController.swift
//  Demo1.0
//
//  Created by User on 2016-11-01.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController {
    
    
    @IBOutlet weak var casinoCheck: UIImageView!
    @IBOutlet weak var hotelCheck: UIImageView!
    @IBOutlet weak var transitCheck: UIImageView!
    @IBOutlet weak var restaurantCheck: UIImageView!
    @IBOutlet weak var barCheck: UIImageView!
    @IBOutlet weak var cafeCheck: UIImageView!
    @IBOutlet weak var allCheck: UIImageView!
    var categoryArray = [String]()
    
    override func viewDidLoad() {
        
        self.tableView.isScrollEnabled = false
        
        if categoryArray.count == 0 || categoryArray.count == 6 {
            
            allCheck.isHidden = false
            cafeCheck.isHidden = false
            hotelCheck.isHidden = false
            transitCheck.isHidden = false
            casinoCheck.isHidden = false
            restaurantCheck.isHidden = false
            barCheck.isHidden = false
            
        } else {
            
            allCheck.isHidden = true
            cafeCheck.isHidden = true
            hotelCheck.isHidden = true
            transitCheck.isHidden = true
            casinoCheck.isHidden = true
            restaurantCheck.isHidden = true
            barCheck.isHidden = true
            
            for cat in categoryArray {
                
                if cat == "Cafe" {
                    cafeCheck.isHidden = false
                } else if cat == "Bar" {
                    barCheck.isHidden = false
                } else if cat == "Restaurant" {
                    restaurantCheck.isHidden = false
                } else if cat == "Transit" {
                    transitCheck.isHidden = false
                } else if cat == "Hotel" {
                    hotelCheck.isHidden = false
                } else if cat == "Casino" {
                    casinoCheck.isHidden = false
                }
                
            }
            
        }
        
        self.categoryArray = [String]()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            print("All was tapped")
            
            if allCheck.isHidden == true {
                allCheck.isHidden = false
                cafeCheck.isHidden = false
                hotelCheck.isHidden = false
                transitCheck.isHidden = false
                casinoCheck.isHidden = false
                restaurantCheck.isHidden = false
                barCheck.isHidden = false
            } else {
                allCheck.isHidden = true
                cafeCheck.isHidden = true
                hotelCheck.isHidden = true
                transitCheck.isHidden = true
                casinoCheck.isHidden = true
                restaurantCheck.isHidden = true
                barCheck.isHidden = true
            }
            
        }
        
        if indexPath.row == 2 {
            print("Cafe was tapped")
            
            if cafeCheck.isHidden == true {
                cafeCheck.isHidden = false
            } else {
                cafeCheck.isHidden = true
                allCheck.isHidden = true
            }
            
        }
        
        if indexPath.row == 3 {
            print("Bar was tapped")
            
            if barCheck.isHidden == true {
                barCheck.isHidden = false
            } else {
                barCheck.isHidden = true
                allCheck.isHidden = true
            }
        }
        
        if indexPath.row == 4 {
            print("Restaurant was tapped")
            
            if restaurantCheck.isHidden == true {
                restaurantCheck.isHidden = false
            } else {
                restaurantCheck.isHidden = true
                allCheck.isHidden = true
            }
        }
        
        if indexPath.row == 5 {
            print("Transit was tapped")
            
            if transitCheck.isHidden == true {
                transitCheck.isHidden = false
            } else {
                transitCheck.isHidden = true
                allCheck.isHidden = true
            }
        }
        
        if indexPath.row == 6 {
            print("Hotel was tapped")
            
            if hotelCheck.isHidden == true {
                hotelCheck.isHidden = false
            } else {
                hotelCheck.isHidden = true
                allCheck.isHidden = true
            }
        }
        
        if indexPath.row == 7 {
            print("Casino was tapped")
            
            if casinoCheck.isHidden == true {
                casinoCheck.isHidden = false
            } else {
                casinoCheck.isHidden = true
                allCheck.isHidden = true
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        // nothing
    }
    
    @IBAction func applyButtonTapped(_ sender: AnyObject) {
        
        if cafeCheck.isHidden == false {
            categoryArray.append("Cafe")
        }
        
        if barCheck.isHidden == false {
            categoryArray.append("Bar")
        }
        
        if restaurantCheck.isHidden == false {
            categoryArray.append("Restaurant")
        }
        
        if transitCheck.isHidden == false {
            categoryArray.append("Transit")
        }
        
        if hotelCheck.isHidden == false {
            categoryArray.append("Hotel")
        }
        
        if casinoCheck.isHidden == false {
            categoryArray.append("Casino")
        }
        
        print(categoryArray)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "applyUnwind" {
            
            let destViewController : VenueListViewController = segue.destination as! VenueListViewController
            
            destViewController.categoryArray = self.categoryArray
            destViewController.filterBool = true
            
        }
    }
    
}
