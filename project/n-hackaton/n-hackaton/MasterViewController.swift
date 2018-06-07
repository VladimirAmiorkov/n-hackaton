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


    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Remove this if editing in the main page is not deisred
        // Do any additional setup after loading the view, typically from a nib.
//        navigationItem.leftBarButtonItem = editButtonItem

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor  = UIColor(red: 88.0/255.0, green: 112.0/255.0, blue: 250.0/255.0, alpha: 1.0);
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        getCarsData();
    }
    
    func getCarsData(){
        let url = URL(string: "https://raw.githubusercontent.com/bugventure/template-master-detail-ng/master/data/cars.json")
        var items = [Car]()
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let stud = try! JSONDecoder().decode(AnyDecodable.self, from: data).value as! [String: Any]
                stud.forEach({ (key, values) in
                    let cars = values as! Dictionary<String, [String: Any]>
                    cars.forEach({ (key, car) in
                        let item = Car(dictionary: car)
                        items.append(item)
                    })
                    DispatchQueue.main.async {
                        items.forEach({ item in
                            self.insertNewObject(item)
                        })
                    }
                    
                })
            }
        }).resume()
        

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ item: Car) {
        objects.insert(item, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! Car
        cell.textLabel!.text = object.name
        // TODO: implement the rich UI here for the list item template
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
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
    init(dictionary: [String: Any]) {
        self.carClass = dictionary["class"] as? String ?? ""
        self.doors = dictionary["doors"] as? Int ?? 0
        self.hasAc = dictionary["hasAc"] as? Bool ?? false
        self.id = dictionary["id"] as? String ?? ""
        self.imageStoragePath = dictionary["imageStoragePath"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.luggage = dictionary["luggage"] as? Int ?? 0
        self.name = dictionary["name"] as? String ?? ""
        self.price = dictionary["price"] as? Int ?? 0
        self.seats = dictionary["seats"] as? Int ?? 0
        self.transmission = dictionary["transmission"] as? String ?? ""
    }
    
    var description: String {
        return name
    }
}

// Generic decoder. TODO: See if there isn't a easier way of parsing/decoding the json data
public struct AnyDecodable: Decodable {
    public var value: Any
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyDecodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}
