//
//  NewPlaceViewController.swift
//  My favorite places
//
//  Created by Nikita on 23.08.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    @IBOutlet var imageOfPlace: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.choiseImagePicker(.camera)
            }
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.choiseImagePicker(.photoLibrary)
            }
            
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
        
        locationTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the location of the place",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        typeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the type of place",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        imageOfPlace.backgroundColor = .black
    }
}


//MARK: - Text Field Delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleToFill
        imageOfPlace.clipsToBounds = true
        dismiss(animated: true)
    }

}
