//
//  NewPlaceViewController.swift
//  My favorite places
//
//  Created by Nikita on 23.08.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    //MARK: - Properties
    
    var currentPlace: Place!
    var imageIsChanged = false
    
    //MARK: - Outlets
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var ratingStackView: RatingControl!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height)
        configureView()
        saveButton.isEnabled = false
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cameraIcon = UIImage(named: "camera")
        let photoLibrary = UIImage(named: "photolibrary")
        
        
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.choiseImagePicker(.camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.choiseImagePicker(.photoLibrary)
            }
            
            photo.setValue(photoLibrary, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true)
            
        } else {
            
            view.endEditing(true)
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "showMapVC" { return }
        
        let mapVC = segue.destination as! MapViewController
        mapVC.place.name = nameTextField.text!
        mapVC.place.location = locationTextField.text
        mapVC.place.type = typeTextField.text
        mapVC.place.imageData = (placeImage.image?.pngData())!

    }
    
    
    //MARK: - Methods
    
    func savePlace() {
        
        let image = imageIsChanged ? placeImage.image : UIImage(named: "nophoto")
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: nameTextField.text!, location: locationTextField.text, type: typeTextField.text, imageData: imageData!, rating: Double(ratingStackView.rating))
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(place: newPlace)
        }
    }
    
    //MARK: - Private
    
    private func configureView() {
        
        tableView.tableFooterView = UIView()
        view.backgroundColor = .black
        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the name of the place",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        nameTextField.textColor = .white
        nameTextField.font = UIFont(name: "", size: 18)
        
        locationTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the location of the place",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        locationTextField.textColor = .white
        locationTextField.font = UIFont(name: "", size: 18)
        
        typeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the type of place",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        typeTextField.textColor = .white
        typeTextField.font = UIFont(name: "", size: 18)
        
        placeImage.backgroundColor = .black
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBarItem()
            imageIsChanged = true
            saveButton.isEnabled = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFit
            nameTextField.text = currentPlace?.name
            locationTextField.text = currentPlace?.location
            typeTextField.text = currentPlace?.type
            ratingStackView.rating = Int(currentPlace.rating)
        }
    }
    
    
    private func setupNavigationBarItem() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = .white
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}


//MARK: - Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        if nameTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}

//MARK: - Image picker

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func choiseImagePicker(_ sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFit
        imageIsChanged = true
        placeImage.clipsToBounds = true
        dismiss(animated: true)
    }
    
}
