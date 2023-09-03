//
//  RatingControl.swift
//  My favorite places
//
//  Created by Nikita on 02.09.2023.
//

import Foundation
import UIKit

class RatingControl: UIStackView {
    
    //MARK: - Properties
    
    @IBInspectable var starButtonSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            createButton()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            createButton()
        }
    }
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    //MARK: - Private
    
    private var starsButtons = [UIButton]()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createButton()
    }
    
    //MARK: - Private methods
    
    private func createButton() {
        
        for button in starsButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        starsButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlitedStar = UIImage(named: "highlitedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlitedStar, for: .highlighted)
            button.setImage(highlitedStar, for: [.highlighted, .selected])
            
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starButtonSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starButtonSize.width).isActive = true
            button.addTarget(self, action: #selector(starsButtonPressed(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            starsButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in starsButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    //MARK: - objc methods
    
    @objc func starsButtonPressed(button: UIButton) {
        
        guard let index = starsButtons.firstIndex(of: button) else { return }
        
         let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
}
