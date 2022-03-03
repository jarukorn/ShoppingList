//
//  MainViewController.swift
//  Shopping Mall
//
//  Created by Jarukorn Thuengjitvilas on 1/3/2565 BE.
//

import UIKit
import FirebaseFirestore

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var contentTableView: UITableView!
    
    var shoppingItems: [ShoppingItemResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Items"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        self.registerCell()
        self.contentTableView.dataSource = self
        self.contentTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        db.collection("items").getDocuments(completion: { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
                
                if let querySnapshot = querySnapshot {
                    self.shoppingItems = querySnapshot.documents.map({ item in
                        return ShoppingItemResponse(imageUrl: item["imageUrl"] as? String ?? "",
                                                    cost: item["cost"] as? Double ?? 0.0,
                                                    title: item["title"] as? String ?? "",
                                                    description: item["description"] as? String ?? "")
                    })
                }
                self.contentTableView.reloadData()
            }
        })
    }
    
    func registerCell() {
        self.contentTableView.register(UINib(nibName: "ShoppingItemTableViewCell", bundle: .main), forCellReuseIdentifier: "ShoppingItemTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemTableViewCell") as? ShoppingItemTableViewCell {
            cell.set(shoppingItemResponse: self.shoppingItems[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func addTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
