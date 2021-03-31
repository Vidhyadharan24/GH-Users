//
//  RoundedView.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

class RoundedView: UIView {
    override var bounds: CGRect {
        didSet {
            setupView()
        }
    }
    
    let borderWidth: CGFloat?
    let borderColor: UIColor?

    init(borderWidth: CGFloat? = nil, borderColor: UIColor? = nil) {
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
        guard let borderWidth = self.borderWidth, let borderColor = self.borderColor else { return }
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

