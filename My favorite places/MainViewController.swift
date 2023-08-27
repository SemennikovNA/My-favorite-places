//
//  MainViewController.swift
//  My favorite places
//
//  Created by Nikita on 21.08.2023.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    //MARK: - Properties
    
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My favorite places"
        places = realm.objects(Place.self)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let row = tableView
        row.backgroundColor = .black
        row.separatorColor = .white
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row]

        cell.backgroundColor = .black

        cell.nameLabel.text = place.name
        cell.nameLabel.textColor = .white
        cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 20)

        cell.locationLabel.text = place.location
        cell.locationLabel.textColor = .white

        cell.typeLabel.text = places[indexPath.row].type
        cell.typeLabel.textColor = .white
        cell.imageOfPlace.image = UIImage(data: place.imageData)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    // MARK: - Tabel view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { _, _ in
            StorageManager.deleteObject(place: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    
    // MARK: - Navigation
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.saveNewPlace()
        tableView.reloadData()
    }

}
