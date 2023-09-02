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
        
        for _ in 0..<starCount {
            
            let button = UIButton()
            button.backgroundColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starButtonSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starButtonSize.width).isActive = true
            button.addTarget(self, action: #selector(starsButtonPressed(button:)), for: .touchUpInside)
            button.layer.cornerRadius = starButtonSize.width / 2
            addArrangedSubview(button)
            starsButtons.append(button)
        }
    }
    
    //MARK: - objc methods
    
    @objc func starsButtonPressed(button: UIButton) {
        print("Button pressed")
    }
    
}
