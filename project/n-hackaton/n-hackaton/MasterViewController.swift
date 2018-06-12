//
//  MasterViewController.swift
//  n-hackaton
//
//  Created by Vladimir Amiorkov on 6/7/18.
//  Copyright © 2018 Vladimir Amiorkov. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    let URL_CARS = "https://raw.githubusercontent.com/VladimirAmiorkov/n-hackaton/master/project/n-hackaton/data/data.json"
    let scaledDownImageWidth = 100
    let scaledDownImageHeight = 83
    let mainBackgroundColor = UIColor.lightGray

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor  = UIColor(red: 88.0/255.0, green: 112.0/255.0, blue: 250.0/255.0, alpha: 1.0);
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.getJsonFromUrl();
    }
    
    func getJsonFromUrl(){
        let url = URL(string: "https://raw.githubusercontent.com/VladimirAmiorkov/n-hackaton/master/data/data.json")
        URLSession.shared.dataTask(with: (url)!, completionHandler: {(data, response, error) -> Void in
            if (error == nil) {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                     let resizedPlaceholderImage = self.resizedImage(image: UIImage(named: "car-placeholder")!, newSize: CGSize(width: self.scaledDownImageWidth, height: self.scaledDownImageHeight))
                    var items = [Car]()
                    if let carsArray = jsonObj!.value(forKey: "cars") as? NSArray {
                        for car in carsArray {
                            if let carDict = car as? NSDictionary {
                                let item = Car(dictionary: carDict, placeholderImage: resizedPlaceholderImage)
                                items.append(item)
                            }
                        }
                    }
                    
                    OperationQueue.main.addOperation({
                        items.forEach({ item in
                            self.insertNewObject(item)
                        })
                    })
                }
            }
        }).resume()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func insertNewObject(_ item: Car) {
        objects.insert(item, at: objects.endIndex)
        let indexPath = IndexPath(row: objects.endIndex - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Car
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
        // TODO measure the cell height
        return 200.0;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterTableViewCell
        cell.selectionStyle = .none
        cell.separator.frame.size.width = (self.navigationController?.view.bounds.width)!
        let object = objects[indexPath.row] as! Car
        cell.nameLabel!.text = object.name
        cell.classLabel!.text = object.carClass
        cell.transitionLabel.text = object.transmission + " Transition"
        var hasAcText = "No"
        if (object.hasAc) {
            hasAcText = "Yes"
        }
        
        cell.acLabel.text = hasAcText
        cell.priceLabel!.text = "€" + String(object.price) + "/day"
        cell.carIconLabel!.text = ""
        cell.cogsIconLabel!.text = ""
        cell.snowIconLabel!.text = ""
        cell.imageView?.image = object.image
        URLSession.shared.dataTask(with: NSURL(string: object.imageUrl)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let resizedCarImage = self.resizedImage(image: UIImage(data: data!)!, newSize: CGSize(width: self.scaledDownImageWidth, height: self.scaledDownImageHeight))
                cell.imageView?.image = resizedCarImage
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            })
        }).resume()
        
        return cell
    }
    
    func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        guard image.size != newSize else { return image }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tempImage!
        
    }

    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}

struct Car: CustomStringConvertible {
    let carClass: String
    let doors : NSInteger
    let hasAc: Bool
    let id: String
    let imageStoragePath: String
    let imageUrl: String
    let luggage: NSInteger
    let name: String
    let price: NSInteger
    let seats: NSInteger
    let transmission: String
    var image: UIImage
    init(dictionary: NSDictionary, placeholderImage: UIImage) {
        self.carClass = dictionary["class"] as? String ?? ""
        self.doors = dictionary["doors"] as? Int ?? 0
        self.hasAc = dictionary["hasAC"] as? Bool ?? false
        self.id = dictionary["id"] as? String ?? ""
        self.imageStoragePath = dictionary["imageStoragePath"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.luggage = dictionary["luggage"] as? Int ?? 0
        self.name = dictionary["name"] as? String ?? ""
        self.price = dictionary["price"] as? Int ?? 0
        self.seats = dictionary["seats"] as? Int ?? 0
        self.transmission = dictionary["transmission"] as? String ?? ""
        self.image = placeholderImage
    }
    
    var description: String {
        return name
    }
}

class MasterTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var transitionLabel: UILabel!
    @IBOutlet weak var acLabel: UILabel!
    @IBOutlet weak var carIconLabel: UILabel!
    @IBOutlet weak var cogsIconLabel: UILabel!
    @IBOutlet weak var snowIconLabel: UILabel!
}
