//
//  OverlayControllerView.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/10/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public class BlockUIViewController: UIViewController {
    public let activityIndicator: UIActivityIndicatorView
    public var textLabel: UILabel
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.textLabel = UILabel()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.textLabel = UILabel()
        
        super.init(coder: aDecoder)
        
        self.setupUI()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
    }
    
    // MARK: - Privates
    
    fileprivate func setupUI() {
        super.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.modalPresentationStyle = .overCurrentContext

        self.activityIndicator.isHidden = false
        
        self.textLabel.textColor = UIColor.white
        
        let stackView = UIStackView(arrangedSubviews: [
            activityIndicator,
            textLabel
        ])
        stackView.axis = .horizontal
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
