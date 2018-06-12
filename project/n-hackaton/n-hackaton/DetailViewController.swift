//
//  DetailViewController.swift
//  n-hackaton
//
//  Created by Vladimir Amiorkov on 6/7/18.
//  Copyright © 2018 Vladimir Amiorkov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var doorsLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var transitionLabel: UILabel!
    @IBOutlet weak var luggageLabel: UILabel!
    
    func configureView() {
        if let detail = detailItem {
            if let carImageView = imageView {
                carImageView.image = detail.image
                URLSession.shared.dataTask(with: NSURL(string: detail.imageUrl)! as URL, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        print(error ?? "No Error")
                        return
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        let image = UIImage(data: data!)
                        carImageView.image = image
                    })
                }).resume()
            }
            
            if let label = priceLabel {
                label.text = "€" + String(detail.price) + "/day"
            }
            
            if let label = classLabel {
                label.text = detail.carClass
            }
            
            if let label = doorsLabel {
                label.text = String(detail.doors)
            }
            
            if let label = seatsLabel {
                label.text = String(detail.seats)
            }
            
            if let label = transitionLabel {
                label.text = detail.transmission + " Transition"
            }
            
            if let label = luggageLabel {
                label.text = String(detail.luggage)
            }
            
            navigationItem.title = detail.name;
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var detailItem: Car? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

