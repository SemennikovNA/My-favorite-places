//
//  MainViewController.swift
//  My favorite places
//
//  Created by Nikita on 21.08.2023.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate {
    
    
    //MARK: - Properties
    
    private var searchResults: Results<Place>!
    private let search = UISearchController(searchResultsController: nil)
    private var isFiltred: Bool {
        return search.isActive && !searchIsEmpty
    }
    private var searchIsEmpty: Bool {
        guard let text = search.searchBar.text else { return false }
        return text.isEmpty
    }
    private var places: Results<Place>!
    private var reversedSort = true
    
    //MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    @IBOutlet var sortingSegmentedControl: UISegmentedControl!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        title = "My favorite places"
        places = realm.objects(Place.self)
        
        //Search configure
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        definesPresentationContext = true
        
        navigationItem.searchController?.searchBar.searchTextField.textColor = .white
        navigationItem.searchController?.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let row = tableView
        row.backgroundColor = .black
        row.separatorColor = .white
        
        if isFiltred {
            return searchResults.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltred {
            place = searchResults[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { _, _ in
            StorageManager.deleteObject(place: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEdit" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceCV = segue.destination as! NewPlaceViewController
            newPlaceCV.currentPlace = place
        }
    }
    
    //MARK: - Actions
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    
    @IBAction func reversedAction(_ sender: Any) {
        reversedSort.toggle()
        sorted()
    }
    
    
    @IBAction func sotredSelection(_ sender: UISegmentedControl) {
        sorted()
    }
    
    
    //MARK: - Private
    
    private func sorted() {
        
        if sortingSegmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: reversedSort)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: reversedSort)
        }
        tableView.reloadData()
    }
}

//MARK: - Search controller delegate

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterSearchContentText(text)
    }
    
    private func filterSearchContentText(_ searchText: String) {
        searchResults = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
