//
//  NewPlaceViewController.swift
//  My favorite places
//
//  Created by Nikita on 23.08.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var newPlace: Place?
    var imageIsChanged = false
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        saveButton.isEnabled = false
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
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
    
    //Configure view
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
    
    func saveNewPlace() {
        
        var image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(named: "nophoto")
        }
        
        
        newPlace = Place(name: nameTextField.text!,
                         location: locationTextField.text,
                         type: typeTextField.text,
                         image: image,
                         restaurantImage: nil)
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
        placeImage.contentMode = .scaleToFill
        imageIsChanged = true
        placeImage.clipsToBounds = true
        dismiss(animated: true)
    }

}
