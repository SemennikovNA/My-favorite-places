//
//  RatingControl.swift
//  My favorite places
//
//  Created by Nikita on 02.09.2023.
//

import Foundation
import UIKit

class RatingControl: UIStackView {
    
    private let starButtonSize: CGSize = (CGSize(width: 44.5, height: 44.5))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        createButton()
    }
    
    
    func createButton() {
        
        let starButton = UIButton()
        starButton.backgroundColor = .white
        
        starButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.heightAnchor.constraint(equalToConstant: starButtonSize.height).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: starButtonSize.width).isActive = true
        
        addArrangedSubview(starButton)
    }
    
}
